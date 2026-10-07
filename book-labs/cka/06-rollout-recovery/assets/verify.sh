#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-06-rollout-recovery
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-rollout get deployment web -o json | json_assert 'd["spec"]["replicas"] == 2 and d["spec"]["template"]["spec"]["containers"][0]["image"] == "nginx:1.28.0"' 'Restore the working image and two desired replicas'
ready_deploy book-cka-rollout web
kubectl -n book-cka-rollout get deployment web -o json | json_assert 'd["spec"]["replicas"] == 2 and d["spec"]["template"]["spec"]["containers"][0]["image"] == "nginx:1.28.0" and d["status"].get("updatedReplicas") == 2 and d["status"].get("availableReplicas") == 2 and d["status"].get("readyReplicas") == 2 and d["status"].get("replicas") == 2' 'Deployment has not fully recovered' 
pass "All checks passed for cka-06-rollout-recovery"
