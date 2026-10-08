#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-07-supply-chain
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubesec scan "$WORK_DIR/repaired.yaml" > "$STATE_DIR/kubesec-current.json"
python3 - "$WORK_DIR" "$STATE_DIR" <<'PYVERIFY'
import json,sys,pathlib
w,s=map(pathlib.Path,sys.argv[1:]);b=json.load(open(w/'reports/kubesec-before.json'))[0];a=json.load(open(w/'reports/kubesec-after.json'))[0];c=json.load(open(s/'kubesec-current.json'))[0]
assert b['score']<0 and a['score']>b['score'] and a['score']==c['score'] and not c.get('scoring',{}).get('critical',[])
PYVERIFY
kubectl -n book-cks-supply get pod scan-target -o json | json_assert 'd["status"]["phase"]=="Running" and d["spec"]["securityContext"]["runAsUser"]==1000 and not d["spec"]["containers"][0]["securityContext"].get("privileged",False)' 'Run the repaired workload'
pass "Step 3: Use Kubesec findings to repair a manifest"
