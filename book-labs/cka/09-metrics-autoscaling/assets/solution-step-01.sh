#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-09-metrics-autoscaling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl top nodes
kubectl top pods -A --sort-by=memory
kubectl top pods -A --sort-by=memory --no-headers | awk 'NR==1 {print $1, $2}' > "$WORK_DIR/highest-memory.txt"
