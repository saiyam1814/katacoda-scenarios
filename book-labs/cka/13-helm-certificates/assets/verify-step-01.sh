#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-13-helm-certificates
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
source "$(dirname -- "${BASH_SOURCE[0]}")/helm.sh"
ensure_helm

"$HELM" history book-cert-manager -n book-cka-cert-manager -o json | json_assert 'len(d)>=3 and d[-1]["status"]=="deployed" and "Rollback to 1" in d[-1]["description"] and all(x["chart"]=="cert-manager-v1.20.4" for x in d)' 'Require pinned install, upgrade and rollback history'
"$HELM" get values book-cert-manager -n book-cka-cert-manager --revision 2 -o json | json_assert 'd.get("replicaCount")==2 and d.get("crds",{}).get("enabled") is True' 'The upgrade revision must actually request two controllers with CRDs retained'
kubectl -n book-cka-cert-manager get deployment book-cert-manager -o json | json_assert 'd["spec"]["replicas"]==1 and d["status"].get("availableReplicas")==1' 'Rollback must restore one available controller'
assert_deploy_ready book-cka-cert-manager book-cert-manager-webhook
assert_deploy_ready book-cka-cert-manager book-cert-manager-cainjector
grep -q 'CustomResourceDefinition' "$WORK_DIR/cert-manager-rendered.yaml" || fail 'Render the chart including CRDs'
pass "Step 1: Install, upgrade and roll back a Helm release"
