#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_pod_ready book-cka-scheduling direct
node=$(cat "$WORK_DIR/node.txt")
test "$(kubectl -n book-cka-scheduling get pod direct -o jsonpath='{.spec.nodeName}')" = "$node" || fail 'Wrong direct node'
kubectl create --dry-run=client -f "$WORK_DIR/direct.yaml" -o json | json_assert 'd["spec"].get("nodeName") and not d["spec"].get("nodeSelector")' 'Submitted manifest must explicitly set nodeName'
pass "Step 2: Assign a Pod directly to a node"
