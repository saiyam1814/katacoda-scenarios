import base64, concurrent.futures, json, pathlib, stat, subprocess, sys, uuid

def run(args, data=None):
    p = subprocess.run(args, input=data, capture_output=True, timeout=4)
    if p.returncode:
        raise ValueError(p.stderr.decode(errors='replace').strip())
    return p.stdout

try:
    state = pathlib.Path(sys.argv[1])
    config = pathlib.Path('/etc/kubernetes/encryption/config.yaml')
    if not config.exists() or stat.S_IMODE(config.stat().st_mode) != 0o600:
        raise ValueError('encryption configuration is missing or not mode0600')
    marker = run(['kubectl', '--request-timeout=3s', '-n', 'cks25', 'get', 'secret', 'database', '-o', 'jsonpath={.data.password}'])
    if base64.b64decode(marker) != b'cks25-lab-marker':
        raise ValueError('API could not decrypt the original marker')
    nonce = uuid.uuid4().hex
    secret = {'apiVersion': 'v1', 'kind': 'Secret', 'metadata': {'name': 'after-encryption', 'namespace': 'cks25'}, 'stringData': {'marker': nonce}}
    run(['kubectl', '--request-timeout=3s', 'apply', '-f', '-'], json.dumps(secret).encode())
    keys = json.loads((state / 'existing-secret-keys.json').read_text()) + ['/registry/secrets/cks25/after-encryption']
    etcd_id = run(['crictl', 'ps', '--name', 'etcd', '-q']).decode().splitlines()[0]
    def check(key):
        value = run(['crictl', 'exec', etcd_id, 'etcdctl', '--command-timeout=2s', '--endpoints=https://127.0.0.1:2379',
            '--cacert=/etc/kubernetes/pki/etcd/ca.crt', '--cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt',
            '--key=/etc/kubernetes/pki/etcd/healthcheck-client.key', 'get', key, '--print-value-only'])
        if not value.startswith(b'k8s:enc:aescbc:v1:key1:') or b'cks25-lab-marker' in value or nonce.encode() in value:
            raise ValueError('existing/new Secret not encrypted with key1: ' + key)
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        list(pool.map(check, keys))
    new = run(['kubectl', '--request-timeout=3s', '-n', 'cks25', 'get', 'secret', 'after-encryption', '-o', 'jsonpath={.data.marker}'])
    if base64.b64decode(new).decode() != nonce:
        raise ValueError('API cannot decrypt a fresh encrypted write')
    print('PASS: all pre-existing Secrets and a fresh write are encrypted in etcd; API decryption works')
except Exception as error:
    sys.exit('FAIL: ' + str(error))
