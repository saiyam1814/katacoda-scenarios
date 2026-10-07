#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-scheduling
node=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
kubectl label node "$node" book-labs.example/disk=ssd --overwrite
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: reporter, namespace: book-cka-scheduling}
spec:
  nodeSelector: {book-labs.example/disk: missing}
  containers:
  - name: reporter
    image: busybox:1.37.0
    command: [sh, -c, 'sleep 3600']
YAML
setup_done
