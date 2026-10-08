#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
kubectl delete namespace book-cka-rollout --ignore-not-found
rm -f "$STATE_DIR/ready"
