#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-02-pod-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl label namespace book-cks-psa pod-security.kubernetes.io/enforce=restricted pod-security.kubernetes.io/enforce-version=v1.35 --overwrite
kubectl -n book-cks-psa delete pod worker --ignore-not-found --wait=true
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: worker, namespace: book-cks-psa}
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    seccompProfile: {type: RuntimeDefault}
  containers:
  - name: worker
    image: busybox:1.37.0
    command: [sh, -c, 'sleep 3600']
    securityContext:
      allowPrivilegeEscalation: false
      capabilities: {drop: [ALL]}
YAML
ready_pod book-cks-psa worker
