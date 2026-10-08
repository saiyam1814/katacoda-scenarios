#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-03-kustomize
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_deploy_ready book-cka-kustomize prod-web
kubectl -n book-cka-kustomize get deployment prod-web -o json | json_assert 'd["spec"]["replicas"]==3 and d["spec"]["template"]["spec"]["containers"][0]["image"]=="nginx:1.28.0" and d["spec"]["selector"]["matchLabels"].get("environment")=="production"' 'Require the requested production overlay'
test -s "$WORK_DIR/app/rendered.yaml" || fail 'Save the rendered application manifest'
kubectl -n book-cka-kustomize exec client -- wget -qO- -T 3 http://prod-web | grep -q 'Welcome to nginx' || fail 'The rendered Service must reach the application'
pass "Step 1: Render and apply an application overlay"
