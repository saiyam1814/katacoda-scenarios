#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
count=$(kubectl get nodes -o json | python3 -c 'import json,sys;print(sum(any(c["type"]=="Ready" and c["status"]=="True" for c in n["status"]["conditions"]) for n in json.load(sys.stdin)["items"]))')
kubectl -n book-cka-scheduling get ds node-web -o json | json_assert "d['status']['desiredNumberScheduled']==$count and d['status'].get('numberReady',0)==$count and d['spec']['template']['spec']['containers'][0]['image']=='nginx:1.28.0'" 'DaemonSet must have one Ready Pod per node'
kubectl -n book-cka-scheduling get pods -l app=node-web -o json | json_assert "len(set(p['spec']['nodeName'] for p in d['items'] if not p['metadata'].get('deletionTimestamp')))==$count" 'Require distinct node placement'
pass "Step 4: Run a DaemonSet on every node"
