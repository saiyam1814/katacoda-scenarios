#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-01-rbac
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-rbac get sa release-bot >/dev/null
kubectl -n book-cka-rbac get role release-manager -o json | json_assert 'len(d["rules"]) == 2 and any(set(r["apiGroups"]) == {"apps"} and set(r["resources"]) == {"deployments"} and set(r["verbs"]) == {"get","list","watch","update","patch"} for r in d["rules"]) and any(set(r["apiGroups"]) == {""} and set(r["resources"]) == {"configmaps"} and set(r["verbs"]) == {"get","list","watch"} for r in d["rules"])' 'Role must contain exactly the requested rules'
kubectl -n book-cka-rbac get rolebinding release-manager -o json | json_assert 'd["roleRef"]["kind"] == "Role" and d["roleRef"]["name"] == "release-manager" and len(d["subjects"]) == 1 and d["subjects"][0]["name"] == "release-bot" and d["subjects"][0]["namespace"] == "book-cka-rbac"' 'Wrong role binding'
identity=system:serviceaccount:book-cka-rbac:release-bot
for verb in get list watch update patch; do can_i yes "$identity" book-cka-rbac "$verb" deployments.apps; done
for verb in get list watch; do can_i yes "$identity" book-cka-rbac "$verb" configmaps; done
for verb in create delete; do can_i no "$identity" book-cka-rbac "$verb" deployments.apps; done
can_i no "$identity" book-cka-rbac get secrets
can_i no "$identity" default patch deployments.apps
pass "All checks passed for cka-01-rbac"
