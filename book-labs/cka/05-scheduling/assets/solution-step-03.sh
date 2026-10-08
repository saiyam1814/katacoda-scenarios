#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: near-anchor, namespace: book-cka-scheduling}
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector: {matchLabels: {role: anchor}}
        topologyKey: kubernetes.io/hostname
  containers: [{name: web, image: 'nginx:1.28.0'}]
YAML
ready_pod book-cka-scheduling near-anchor
