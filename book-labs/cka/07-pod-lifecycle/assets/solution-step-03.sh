#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-07-pod-lifecycle
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "multi",
    "namespace": "book-cka-pods"
  },
  "spec": {
    "containers": [
      {
        "name": "web",
        "image": "nginx:1.28.0"
      },
      {
        "name": "database",
        "image": "redis:7.4.5"
      }
    ]
  }
}
YAML
ready_pod book-cka-pods multi
kubectl -n book-cka-pods exec multi -c database -- redis-cli -h 127.0.0.1 ping
