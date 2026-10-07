#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-01-rbac
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-rbac create serviceaccount release-bot --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata: {name: release-manager, namespace: book-cka-rbac}
rules:
- apiGroups: [apps]
  resources: [deployments]
  verbs: [get, list, watch, update, patch]
- apiGroups: [""]
  resources: [configmaps]
  verbs: [get, list, watch]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata: {name: release-manager, namespace: book-cka-rbac}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: Role, name: release-manager}
subjects:
- {kind: ServiceAccount, name: release-bot, namespace: book-cka-rbac}
YAML
