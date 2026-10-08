#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
NODE=$(cat "$WORK_DIR/node.txt")
cat > "$WORK_DIR/direct.yaml" <<YAML
apiVersion: v1
kind: Pod
metadata: {name: direct, namespace: book-cka-scheduling}
spec:
  nodeName: $NODE
  containers: [{name: web, image: 'nginx:1.28.0'}]
YAML
kubectl apply -f "$WORK_DIR/direct.yaml"
ready_pod book-cka-scheduling direct
