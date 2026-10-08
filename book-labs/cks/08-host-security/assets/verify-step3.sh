#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-08-host-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
test "$(kubectl get runtimeclass book-sandbox -o jsonpath='{.handler}')" = runsc
test "$(kubectl -n book-cks-host get pod sandbox -o jsonpath='{.spec.runtimeClassName}')" = book-sandbox
kubectl -n book-cks-host exec sandbox -- dmesg | grep -qiE 'gvisor|runsc|Starting gVisor'
grep -qiE 'gvisor|runsc' "$WORK_DIR/sandbox-runtime.txt"
kubectl -n book-cks-host get events --field-selector involvedObject.name=missing -o json | python3 -c 'import json,sys;d=json.load(sys.stdin);assert any(x.get("reason")=="FailedCreatePodSandBox" and "does-not-exist" in x.get("message","") for x in d["items"])'
grep -q 'does-not-exist' "$WORK_DIR/missing-runtime.txt"
pass "Step 3: Run a workload inside gVisor"
