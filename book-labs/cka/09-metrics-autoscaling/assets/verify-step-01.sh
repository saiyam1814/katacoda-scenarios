#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-09-metrics-autoscaling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
source "$(dirname -- "${BASH_SOURCE[0]}")/metrics.sh"

[[ -r "$WORK_DIR/highest-memory.txt" && -s "$WORK_DIR/highest-memory.txt" ]] || fail "Save a readable, nonempty highest-memory.txt with the namespace and Pod name"
metrics_check
kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods > "$STATE_DIR/pod-metrics.json"
python3 - "$STATE_DIR/pod-metrics.json" "$WORK_DIR/highest-memory.txt" <<'PYRANK'
import json,pathlib,sys,re
items=json.loads(pathlib.Path(sys.argv[1]).read_text())['items']
def memory(value):
 m=re.fullmatch(r'([0-9.]+)([A-Za-z]*)',value); scale={'':1,'Ki':1024,'Mi':1024**2,'Gi':1024**3,'K':1000,'M':1000**2,'G':1000**3};return float(m[1])*scale[m[2]]
assert len(items)>=2, 'Require live metrics across namespaces'
rank=sorted(items,key=lambda p:sum(memory(c['usage']['memory']) for c in p['containers']),reverse=True)
assert pathlib.Path(sys.argv[2]).read_text().strip()==rank[0]['metadata']['namespace']+' '+rank[0]['metadata']['name'], 'Save namespace and Pod name for current highest memory usage'
PYRANK
pass "Step 1: Find the highest memory consumer from live metrics"
