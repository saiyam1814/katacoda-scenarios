#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-04-serviceaccount
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cks-identity
kubectl -n book-cks-identity create configmap settings --from-literal=mode=demo
kubectl -n book-cks-identity create configmap other --from-literal=mode=private
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: ServiceAccount
metadata: {name: reader, namespace: book-cks-identity}
automountServiceAccountToken: true
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata: {name: reader, namespace: book-cks-identity}
rules:
- apiGroups: ['*']
  resources: ['*']
  verbs: ['*']
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata: {name: reader, namespace: book-cks-identity}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: Role, name: reader}
subjects: [{kind: ServiceAccount, name: reader, namespace: book-cks-identity}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: worker, namespace: book-cks-identity}
spec:
  replicas: 1
  selector:
    matchLabels: {app: worker}
  template:
    metadata:
      labels: {app: worker}
    spec:
      serviceAccountName: reader
      automountServiceAccountToken: true
      containers:
      - name: worker
        image: busybox:1.37.0
        command: [sh, -c, 'sleep 3600']
YAML
ready_deploy book-cks-identity worker
setup_done
