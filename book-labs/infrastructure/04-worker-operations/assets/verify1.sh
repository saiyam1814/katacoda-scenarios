#!/usr/bin/env bash
LAB_ID=infra-04-worker-operations
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
remote systemctl is-active --quiet kubelet || fail 'Worker kubelet is inactive'
k get node node01 -o json | json_check 'any(c["type"]=="Ready" and c["status"]=="True" for c in d["status"]["conditions"])' 'Worker is not Ready'
k -n cka20 get pod probe -o json | json_check 'd["spec"]["nodeName"]=="node01" and d["spec"].get("nodeSelector",{}).get("kubernetes.io/hostname")=="node01" and any(c["type"]=="Ready" and c["status"]=="True" for c in d["status"].get("conditions",[]))' 'Fresh probe must be Ready on node01 via nodeSelector'
[[ "$(k -n cka20 exec probe -- printf kubelet-working)" == kubelet-working ]] || fail 'Authenticated execution failed'
test -s /tmp/cka20-root-cause.txt || fail 'Save the cause and recovery note'
python3 - <<'EOF'
import pathlib,sys
s=pathlib.Path('/tmp/cka20-root-cause.txt').read_text().lower()
if not all(t in s for t in ['kubelet','node01','stop','start']):sys.exit('FAIL: the cause/recovery note must identify the stopped kubelet and recovery on node01')
EOF
pass 'Kubelet recovered; new scheduled Pod and authenticated exec work'
