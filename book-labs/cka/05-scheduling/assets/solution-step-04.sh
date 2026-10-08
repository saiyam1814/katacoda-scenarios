#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: DaemonSet
metadata: {name: node-web, namespace: book-cka-scheduling}
spec:
  selector: {matchLabels: {app: node-web}}
  template:
    metadata: {labels: {app: node-web}}
    spec:
      tolerations:
      - {key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}
      - {key: node-role.kubernetes.io/master, operator: Exists, effect: NoSchedule}
      containers: [{name: web, image: 'nginx:1.28.0'}]
YAML
kubectl -n book-cka-scheduling rollout status daemonset/node-web --timeout=180s
