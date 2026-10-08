#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-08-static-pods-logs
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
NODE=$(first_node)
assert_pod_ready book-cka-hostpods "book-cka-static-$NODE"
test -s "$WORK_DIR/mirror-before.txt" || fail 'Record original mirror UID'
current=$(kubectl -n book-cka-hostpods get pod "book-cka-static-$NODE" -o jsonpath='{.metadata.uid}')
[[ "$current" != "$(cat "$WORK_DIR/mirror-before.txt")" ]] || fail 'Mirror Pod has not been recreated'
pass "Step 2: Observe mirror-Pod recreation"
