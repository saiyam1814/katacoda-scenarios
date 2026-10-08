#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-rollout patch deployment update-demo --type=strategic -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxUnavailable":0,"maxSurge":1}},"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.28.0"}]}}}}'
ready_deploy book-cka-rollout update-demo
