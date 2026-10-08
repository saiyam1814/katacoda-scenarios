#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-03-kustomize
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/metrics.sh"
metrics_cleanup
kubectl delete namespace book-cka-kustomize --ignore-not-found
rm -f "$STATE_DIR/ready"
