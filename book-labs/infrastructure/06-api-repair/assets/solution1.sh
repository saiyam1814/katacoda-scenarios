#!/usr/bin/env bash
LAB_ID=infra-06-api-repair
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
crictl ps -a --name kube-apiserver
cat > "$WORK_DIR/fix.json" <<'EOF'
{"flags":{"client-ca-file":"/etc/kubernetes/pki/ca.crt"}}
EOF
api_patch "$WORK_DIR/fix.json"
api_wait
ns cka37
k -n cka37 run verify --image=busybox:1.37.0 --restart=Never --command -- sleep 3600
ready_pod cka37 verify
k -n cka37 exec verify -- nslookup kubernetes.default.svc.cluster.local
python3 - <<'EOF'
import json,pathlib,subprocess
nodes=json.loads(subprocess.check_output(['kubectl','get','nodes','-o','json']))
csi=json.loads(subprocess.check_output(['kubectl','get','csidrivers','-o','json']))
d={'runtime':nodes['items'][0]['status']['nodeInfo']['containerRuntimeVersion'],'cni_files':sorted(p.name for p in pathlib.Path('/etc/cni/net.d').iterdir() if p.is_file()),'csi_drivers':sorted(x['metadata']['name'] for x in csi['items']) or ['none']}
pathlib.Path('/tmp/cka37-interfaces.json').write_text(json.dumps(d,indent=2)+'\n')
EOF
