#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-07-pod-lifecycle
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_pod_ready book-cka-pods saiyam
kubectl -n book-cka-pods get pod saiyam -o json | json_assert 'd["spec"]["containers"][0]["image"]=="nginx:1.28.0"' 'Wrong image'
test "$(cat "$WORK_DIR/image.txt")" = nginx:1.28.0 || fail "Save only the image name"
pass "Step 1: Create a Pod and extract only its image"
