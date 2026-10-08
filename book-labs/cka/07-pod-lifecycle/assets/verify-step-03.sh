#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-07-pod-lifecycle
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_pod_ready book-cka-pods multi
kubectl -n book-cka-pods get pod multi -o json | json_assert 'len(d["spec"]["containers"])==2 and {c["name"] for c in d["spec"]["containers"]}=={"web","database"}' 'Both containers belong to one Pod'
test "$(kubectl -n book-cka-pods exec multi -c database -- redis-cli -h 127.0.0.1 ping)" = PONG || fail "Redis localhost request failed"
pass "Step 3: Share a Pod network namespace"
