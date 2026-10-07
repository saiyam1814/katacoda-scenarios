#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-scheduling delete pod reporter --wait=true
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: reporter, namespace: book-cka-scheduling}
spec:
  nodeSelector: {book-labs.example/disk: ssd}
  containers:
  - name: reporter
    image: busybox:1.37.0
    command: [sh, -c, 'sleep 3600']
YAML
ready_pod book-cka-scheduling reporter
