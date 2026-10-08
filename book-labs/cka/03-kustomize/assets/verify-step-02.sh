#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-03-kustomize
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
source "$(dirname -- "${BASH_SOURCE[0]}")/metrics.sh"

metrics_check
test -s "$WORK_DIR/metrics/rendered.yaml" || fail 'Save the rendered component manifest'
kubectl kustomize "$WORK_DIR/metrics/overlay" > "$STATE_DIR/component-current.yaml"
pass "Step 2: Patch and install a real metrics component"
