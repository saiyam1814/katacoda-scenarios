#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-01-rbac
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-rbac get rolebinding demo-create -o json | json_assert 'd["roleRef"]["kind"]=="ClusterRole" and d["roleRef"]["name"]=="book-cka-creators"' 'Use a namespaced RoleBinding to the ClusterRole'
for sa in demo-sa demo2-sa; do
 can_i yes "system:serviceaccount:book-cka-rbac:$sa" book-cka-rbac create deployments.apps
 can_i no "system:serviceaccount:book-cka-rbac:$sa" default create deployments.apps
 can_i no "system:serviceaccount:book-cka-rbac:$sa" book-cka-rbac get secrets
done
can_i yes system:serviceaccount:book-cka-rbac:demo-sa book-cka-rbac create daemonsets.apps
can_i no system:serviceaccount:book-cka-rbac:demo2-sa book-cka-rbac create daemonsets.apps
pass "Step 2: Bind reusable rules within one namespace"
