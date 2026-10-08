import json, pathlib, subprocess, sys, uuid, yaml

def request(args, body=None):
    p = subprocess.run(['kubectl', '--request-timeout=3s'] + args,
        input=None if body is None else json.dumps(body), capture_output=True, text=True, timeout=4)
    if p.returncode:
        raise ValueError('audit test request failed: ' + p.stderr.strip())
    return p.stdout

name = 'audit-check-' + uuid.uuid4().hex[:10]
created_deployment = created_secret = False
try:
    manifest = yaml.safe_load(pathlib.Path('/etc/kubernetes/manifests/kube-apiserver.yaml').read_text())
    flags = dict(x[2:].split('=', 1) for x in manifest['spec']['containers'][0]['command'] if x.startswith('--') and '=' in x)
    expected = {'audit-log-path': '/var/log/kubernetes/audit/audit.log', 'audit-log-maxage': '30',
        'audit-log-maxbackup': '10', 'audit-log-maxsize': '100', 'audit-log-mode': 'blocking'}
    if any(flags.get(k) != v for k, v in expected.items()):
        raise ValueError('audit log flags are incomplete')
    request(['get', 'deployment', 'web', '-n', 'cks06', '-o', 'name'])
    request(['get', 'secret', 'marker', '-n', 'cks06', '-o', 'name'])
    # Replicas zero avoids launching disposable workload Pods for each CHECK.
    deployment = {'apiVersion': 'apps/v1', 'kind': 'Deployment', 'metadata': {'name': name, 'namespace': 'cks06'},
        'spec': {'replicas': 0, 'selector': {'matchLabels': {'app': name}}, 'template': {
            'metadata': {'labels': {'app': name}}, 'spec': {'containers': [{'name': 'web', 'image': 'nginx:1.28.0-alpine'}]}}}}
    request(['create', '-f', '-'], deployment); created_deployment = True
    patched = json.loads(request(['patch', 'deployment', name, '-n', 'cks06', '--type=merge', '-p',
        json.dumps({'metadata': {'annotations': {'patch': name}}}), '-o', 'json']))
    for attempt in range(4):
        # The Deployment controller may update status immediately after creation.
        updated = json.loads(request(['get', 'deployment', name, '-n', 'cks06', '-o', 'json']))
        updated['metadata']['annotations']['update'] = name
        try:
            request(['replace', '-f', '-'], updated)
            break
        except ValueError as error:
            if 'Conflict' not in str(error) or attempt == 3:
                raise
    request(['delete', 'deployment', name, '-n', 'cks06', '--wait=false']); created_deployment = False
    request(['create', 'secret', 'generic', name, '-n', 'cks06', '--from-literal=token=disposable-audit-marker']); created_secret = True
    events = []
    for line in pathlib.Path(expected['audit-log-path']).read_text().splitlines():
        try: event = json.loads(line)
        except ValueError: continue
        if event.get('stage') == 'ResponseComplete' and event.get('objectRef', {}).get('namespace') == 'cks06':
            events.append(event)
    deployments = [e for e in events if e.get('objectRef', {}).get('resource') == 'deployments' and e['objectRef'].get('name') == name and not e['objectRef'].get('subresource')]
    for verb in ('create', 'update', 'patch', 'delete'):
        matching = [e for e in deployments if e.get('verb') == verb]
        if not matching or not any(200 <= e.get('responseStatus', {}).get('code', 0) < 300 for e in matching) or not all(e.get('level') == 'RequestResponse' and 'requestObject' in e and 'responseObject' in e for e in matching):
            raise ValueError('fresh Deployment ' + verb + ' lacks RequestResponse bodies')
    secrets = [e for e in events if e.get('objectRef', {}).get('resource') == 'secrets']
    if not any(e['objectRef'].get('name') == name and e.get('verb') == 'create' for e in secrets):
        raise ValueError('fresh unique Secret audit event is missing')
    if any(e.get('level') != 'Metadata' or 'requestObject' in e or 'responseObject' in e for e in secrets):
        raise ValueError('Secret bodies were leaked to audit logs')
    print('PASS: all four live Deployment verbs have bodies; a fresh Secret event has metadata only')
except Exception as error:
    sys.exit('FAIL: ' + str(error))
finally:
    if created_deployment:
        subprocess.run(['kubectl', '--request-timeout=2s', 'delete', 'deployment', name, '-n', 'cks06', '--wait=false'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=3)
    if created_secret:
        subprocess.run(['kubectl', '--request-timeout=2s', 'delete', 'secret', name, '-n', 'cks06', '--wait=false'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=3)
