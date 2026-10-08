#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-07-pod-lifecycle
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-pods get pod shared -o json | json_assert 'd["spec"]["restartPolicy"]=="Never" and d["status"]["phase"]=="Succeeded" and len(d["spec"]["containers"])==3 and all(c["state"]["terminated"]["exitCode"]==0 for c in d["status"]["containerStatuses"]) and any("emptyDir" in v for v in d["spec"]["volumes"])' 'All three shared-volume containers must finish successfully'
test "$(kubectl -n book-cka-pods logs shared -c c3)" = "$(printf "Hello from c1 container.\nHello from c2 container.")" || fail "Reader must consume both writers"
pass "Step 5: Coordinate ordinary containers through a shared volume"
