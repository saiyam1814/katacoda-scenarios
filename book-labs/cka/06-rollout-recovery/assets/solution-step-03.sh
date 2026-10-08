#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-rollout rollout history deployment/web
kubectl -n book-cka-rollout rollout undo deployment/web --to-revision=1
ready_deploy book-cka-rollout web
kubectl -n book-cka-rollout rollout history deployment/web > "$WORK_DIR/history.txt"
