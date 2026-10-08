#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-rollout rollout history deployment/web
kubectl -n book-cka-rollout patch deployment web --type=strategic -p '{"metadata":{"annotations":{"kubernetes.io/change-cause":"Successful upgrade"}},"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.28.0"}]}}}}'
ready_deploy book-cka-rollout web
kubectl -n book-cka-rollout get deployment web -o json > "$WORK_DIR/successful-upgrade.json"
kubectl -n book-cka-rollout rollout undo deployment/web --to-revision=1
ready_deploy book-cka-rollout web
kubectl -n book-cka-rollout rollout history deployment/web > "$WORK_DIR/history.txt"
