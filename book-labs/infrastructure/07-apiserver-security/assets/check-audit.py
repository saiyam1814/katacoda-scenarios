import json,pathlib,subprocess,sys,uuid,yaml
try:
 manifest=yaml.safe_load(pathlib.Path('/etc/kubernetes/manifests/kube-apiserver.yaml').read_text())
 flags=dict(x[2:].split('=',1) for x in manifest['spec']['containers'][0]['command'] if x.startswith('--') and '=' in x)
 expected={'audit-log-path':'/var/log/kubernetes/audit/audit.log','audit-log-maxage':'30','audit-log-maxbackup':'10','audit-log-maxsize':'100','audit-log-mode':'blocking'}
 if any(flags.get(k)!=v for k,v in expected.items()):raise ValueError('audit log flags are incomplete')
 nonce=uuid.uuid4().hex
 for args in (['patch','deployment','web','-n','cks06','--type=merge','-p',json.dumps({'metadata':{'annotations':{'book-check':nonce}}})],['get','secret','marker','-n','cks06','-o','name']):
  p=subprocess.run(['kubectl','--request-timeout=3s']+args,capture_output=True,text=True,timeout=4)
  if p.returncode:raise ValueError('audit test request failed: '+p.stderr.strip())
 events=[]
 for line in pathlib.Path(expected['audit-log-path']).read_text().splitlines():
  try:e=json.loads(line)
  except ValueError:continue
  if e.get('stage')=='ResponseComplete' and e.get('objectRef',{}).get('namespace')=='cks06':events.append(e)
 deployments=[e for e in events if e.get('objectRef',{}).get('resource')=='deployments' and e.get('verb')=='patch' and e.get('requestObject',{}).get('metadata',{}).get('annotations',{}).get('book-check')==nonce]
 if not deployments or not all(e.get('level')=='RequestResponse' and 'responseObject' in e for e in deployments):raise ValueError('fresh Deployment patch lacks RequestResponse bodies')
 secrets=[e for e in events if e.get('objectRef',{}).get('resource')=='secrets' and e.get('objectRef',{}).get('name')=='marker']
 if not secrets or not any(e.get('verb')=='get' for e in secrets):raise ValueError('Secret audit event is missing')
 if any(e.get('level')!='Metadata' or 'requestObject' in e or 'responseObject' in e for e in secrets):raise ValueError('Secret bodies were leaked to audit logs')
 print('PASS: fresh live Deployment and Secret audit events have the required levels and bodies')
except Exception as e:sys.exit('FAIL: '+str(e))
