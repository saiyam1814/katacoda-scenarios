#!/usr/bin/env bash
LAB_ID=infra-04-worker-operations
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
k get node node01 -o json | json_check 'not d["spec"].get("unschedulable",False) and any(c["type"]=="Ready" and c["status"]=="True" for c in d["status"]["conditions"])' 'Worker must be Ready and schedulable'
k -n cka23 get pod restored -o json | json_check 'd["spec"].get("nodeName")=="node01" and d["spec"].get("nodeSelector",{}).get("kubernetes.io/hostname")=="node01" and any(c["type"]=="Ready" and c["status"]=="True" for c in d["status"].get("conditions",[]))' 'Fresh post-maintenance Pod is not Ready on worker'
k -n cka23 get pods -l app=resident -o json > "$STATE_DIR/resident-after.json"
python3 - "$STATE_DIR" <<'EOF'
import json,pathlib,sys
p=pathlib.Path(sys.argv[1]);old=json.loads((p/'resident-before.json').read_text())['items'][0]['metadata']['uid'];items=json.loads((p/'resident-after.json').read_text())['items']
if not any(x['metadata']['uid']!=old and x['spec'].get('nodeName')!='node01' and any(c['type']=='Ready' and c['status']=='True' for c in x.get('status',{}).get('conditions',[])) for x in items):sys.exit('FAIL: original Deployment Pod was not replaced by a Ready Pod on the other node')
EOF
pass 'Drained workload recovered elsewhere; worker schedules a fresh Pod after uncordon'
