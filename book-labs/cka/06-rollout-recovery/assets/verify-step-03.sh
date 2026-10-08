#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_deploy_ready book-cka-rollout web
kubectl -n book-cka-rollout get deployment web -o json | json_assert 'd["spec"]["replicas"]==2 and d["spec"]["template"]["spec"]["containers"][0]["image"]=="nginx:1.27.5" and int(d["metadata"]["annotations"]["deployment.kubernetes.io/revision"])>=3' 'Restore working image through a new rollout revision'
kubectl -n book-cka-rollout get rs -l app=web -o json | json_assert 'any(r["metadata"].get("annotations",{}).get("kubernetes.io/change-cause")=="Broken release" for r in d["items"]) and any(r["metadata"].get("annotations",{}).get("kubernetes.io/change-cause")=="Working release" for r in d["items"])' 'Retain accurate change-cause history'
grep -q 'Working release' "$WORK_DIR/history.txt" || fail 'Save observed rollout history'
pass "Step 3: Inspect history and recover the broken rollout"
