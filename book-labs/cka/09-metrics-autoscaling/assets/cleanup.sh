#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-09-metrics-autoscaling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/metrics.sh"
kubectl delete namespace book-cka-metrics book-cka-hpa --ignore-not-found
metrics_cleanup
rm -f "$STATE_DIR/ready"
