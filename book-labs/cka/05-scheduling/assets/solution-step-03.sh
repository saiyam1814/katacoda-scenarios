#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-scheduling run anchor --image=nginx:1.28.0 --labels=role=anchor
ready_pod book-cka-scheduling anchor
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
  containers: [{name: database, image: 'redis:7.4.5'}]
YAML
ready_pod book-cka-scheduling near-anchor
