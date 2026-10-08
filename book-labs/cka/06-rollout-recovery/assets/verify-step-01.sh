#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_deploy_ready book-cka-rollout created
kubectl -n book-cka-rollout get deployment created -o json | json_assert 'd["spec"]["replicas"]==3 and d["spec"]["template"]["spec"]["containers"][0]["image"]=="nginx:1.28.0"' 'Create three requested replicas'
test -s "$WORK_DIR/created.yaml" || fail 'Save live YAML'
kubectl create --dry-run=client -f "$WORK_DIR/created.yaml" -o json | json_assert 'd["kind"]=="Deployment" and d["metadata"]["name"]=="created" and d["spec"]["replicas"]==3' 'Saved YAML is not this Deployment'
pass "Step 1: Create and inspect a Deployment"
