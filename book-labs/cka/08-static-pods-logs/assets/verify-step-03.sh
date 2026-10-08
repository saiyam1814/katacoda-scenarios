#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-08-static-pods-logs
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
test "$(cat "$WORK_DIR/c2.txt")" = c2-required-log || fail 'Select c2 rather than the default container'
test "$(cat "$WORK_DIR/previous.txt")" = 'ERROR: missing configuration' || fail 'Save previous-instance crash logs'
kubectl -n book-cka-hostpods get pod crash -o json | json_assert 'd["status"]["containerStatuses"][0]["restartCount"]>=1' 'Require an actual restarted container'
pass "Step 3: Extract the correct container and previous-instance logs"
