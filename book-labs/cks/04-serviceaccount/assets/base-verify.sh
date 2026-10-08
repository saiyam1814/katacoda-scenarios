#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-04-serviceaccount
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
identity=system:serviceaccount:book-cks-identity:reader
can_i yes "$identity" book-cks-identity get configmap/settings
can_i no "$identity" book-cks-identity get configmap/other
can_i no "$identity" book-cks-identity list configmaps
can_i no "$identity" book-cks-identity get secrets
can_i no "$identity" default get configmap/settings
kubectl -n book-cks-identity get role reader -o json | json_assert 'len(d["rules"]) == 1 and set(d["rules"][0]["apiGroups"]) == {""} and set(d["rules"][0]["resources"]) == {"configmaps"} and set(d["rules"][0]["resourceNames"]) == {"settings"} and set(d["rules"][0]["verbs"]) == {"get"}' 'Role must contain only the named ConfigMap permission'
kubectl -n book-cks-identity get rolebinding reader -o json | json_assert 'd["roleRef"]["kind"] == "Role" and d["roleRef"]["name"] == "reader" and len(d["subjects"]) == 1 and d["subjects"][0]["kind"] == "ServiceAccount" and d["subjects"][0]["name"] == "reader" and d["subjects"][0]["namespace"] == "book-cks-identity"' 'Preserve the namespaced RoleBinding to reader'
kubectl -n book-cks-identity get sa reader -o json | json_assert 'd.get("automountServiceAccountToken") is False' 'Disable token mounting on ServiceAccount'
ready_deploy book-cks-identity worker
kubectl -n book-cks-identity get deploy worker -o json | json_assert 'd["spec"]["template"]["spec"].get("automountServiceAccountToken") is False and d["spec"]["template"]["spec"]["serviceAccountName"] == "reader"' 'Disable Pod token mounting while preserving the account'
pod=$(one_ready_pod book-cks-identity app=worker)
kubectl -n book-cks-identity exec "$pod" -- sh -c 'test ! -e /var/run/secrets/kubernetes.io/serviceaccount/token'
kubectl -n book-cks-identity get pod "$pod" -o json | json_assert 'not any("projected" in v and any("serviceAccountToken" in s for s in v["projected"]["sources"]) for v in d["spec"].get("volumes",[]))' 'No projected service account token volume may remain' 
pass "All checks passed for cks-04-serviceaccount"
