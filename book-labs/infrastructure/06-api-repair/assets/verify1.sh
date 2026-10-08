#!/usr/bin/env bash
LAB_ID=infra-06-api-repair
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
k get --raw=/readyz >/dev/null || fail 'API is unavailable'
python3 - "$WORK_DIR" <<'EOF'
import yaml,sys,pathlib,json,subprocess
before=yaml.safe_load((pathlib.Path(sys.argv[1])/'kube-apiserver.before.yaml').read_text());after=yaml.safe_load(pathlib.Path('/etc/kubernetes/manifests/kube-apiserver.yaml').read_text())
for doc in (before,after):doc['spec']['containers'][0]['command']=sorted(doc['spec']['containers'][0]['command'])
if before!=after:sys.exit('FAIL: restore only the incorrect client-CA field, preserving the original manifest')
try:
 d=json.loads(pathlib.Path('/tmp/cka37-interfaces.json').read_text());nodes=json.loads(subprocess.check_output(['kubectl','--request-timeout=3s','get','nodes','-o','json']));drivers=json.loads(subprocess.check_output(['kubectl','--request-timeout=3s','get','csidrivers','-o','json']))
 expected={'runtime':nodes['items'][0]['status']['nodeInfo']['containerRuntimeVersion'],'cni_files':sorted(p.name for p in pathlib.Path('/etc/cni/net.d').iterdir() if p.is_file()),'csi_drivers':sorted(x['metadata']['name'] for x in drivers['items']) or ['none']}
 if d!=expected:raise ValueError('evidence does not match actual interfaces')
except Exception as e:sys.exit('FAIL: interface evidence missing or incorrect: '+str(e))
EOF
k -n cka37 exec verify -- nslookup kubernetes.default.svc.cluster.local >/dev/null || fail 'Fresh Pod DNS lookup failed'
pass 'API restored, fresh Pod DNS works, interface evidence matches the cluster'
