#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-rollout create deployment created --image=nginx:1.28.0 --replicas=3
ready_deploy book-cka-rollout created
kubectl -n book-cka-rollout get deployment created -o yaml > "$WORK_DIR/created.yaml"
