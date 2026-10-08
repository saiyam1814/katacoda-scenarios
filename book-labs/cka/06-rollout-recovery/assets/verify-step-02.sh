#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_deploy_ready book-cka-rollout update-demo
kubectl -n book-cka-rollout get deployment update-demo -o json | json_assert 'd["spec"]["replicas"]==4 and d["spec"]["strategy"]["rollingUpdate"]=={"maxSurge":1,"maxUnavailable":0} and d["spec"]["template"]["spec"]["containers"][0]["image"]=="nginx:1.28.0"' 'Preserve replicas and requested rollout strategy'
kubectl -n book-cka-rollout get pods -l app=update-demo -o json | json_assert 'all(p["spec"]["containers"][0]["image"]=="nginx:1.28.0" for p in d["items"] if not p["metadata"].get("deletionTimestamp"))' 'Old-image Pods remain'
pass "Step 2: Update an image with rolling availability"
