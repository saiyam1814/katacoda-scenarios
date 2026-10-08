#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-01-rbac
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-rbac create sa demo-sa --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: web-identity, namespace: book-cka-rbac}
spec:
  serviceAccountName: demo-sa
  automountServiceAccountToken: false
  containers:
  - {name: web, image: 'nginx:1.28.0'}
YAML
ready_pod book-cka-rbac web-identity
