#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-08-host-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
test "$(stat -c %a /etc/kubernetes/manifests/kube-controller-manager.yaml)" = 600
pgrep -af '^kube-controller-manager.*--profiling=false' >/dev/null
kube-bench run --benchmark cis-1.12 --config-dir /opt/book-tools/kube-bench/cfg --config /opt/book-tools/kube-bench/cfg/config.yaml --check 1.1.3,1.3.2,4.1.9 --json > "$STATE_DIR/cis-check.json"
python3 - "$WORK_DIR/cis-before.json" "$WORK_DIR/cis-after.json" "$STATE_DIR/cis-check.json" <<'PYVERIFY'
import json,sys
def results(p):
 d=json.load(open(p)); out={}
 def walk(v):
  if isinstance(v,dict):
   if v.get('test_number') in ('1.1.3','1.3.2','4.1.9'):out[v['test_number']]=v['status']
   for x in v.values():walk(x)
  elif isinstance(v,list):
   for x in v:walk(x)
 walk(d);return out
assert results(sys.argv[1])=={'1.1.3':'FAIL','1.3.2':'FAIL','4.1.9':'FAIL'}
for p in sys.argv[2:]:assert results(p)=={'1.1.3':'PASS','1.3.2':'PASS','4.1.9':'PASS'},results(p)
PYVERIFY
python3 - "$WORK_DIR/cis-review.json" <<'PYVERIFY'
import json,sys
assert json.load(open(sys.argv[1])), 'Capture the actual broader benchmark report'
PYVERIFY
test -s "$WORK_DIR/coredns-review.yaml"
pass "Step 1: Remediate actual CIS benchmark findings"
