#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-10-incident-investigation
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
sha256sum -c "$STATE_DIR/incident-original.sha256"
python3 - "$WORK_DIR" "$STATE_DIR/actor-ip" <<'PYVERIFY'
import pathlib,json,sys
p=pathlib.Path(sys.argv[1]);rows=[json.loads(x) for x in (p/'incident.jsonl').read_text().splitlines()];assert len(rows)>=3
assert all(x['stage']=='ResponseComplete' and 'requestObject' not in x and 'responseObject' not in x for x in rows)
f=json.load(open(p/'findings.json'));assert f=={'actor':'system:serviceaccount:book-cks-incident:actor','sourceIP':pathlib.Path(sys.argv[2]).read_text(),'secretRead':200,'crossNamespaceRead':403,'deletedPod':'victim','targetSecret':'payments','activity':['get','list','delete']},f
assert len((p/'response-plan.md').read_text().split())>=30
PYVERIFY
pass "Step 1: Investigate the actual audit trail"
