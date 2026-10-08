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
    "name": "log-demo",
    "namespace": "book-cka-pods"
  },
  "spec": {
    "containers": [
      {
        "name": "writer",
        "image": "busybox:1.37.0",
        "command": [
          "sh",
          "-c",
          "while true; do echo \"learning Kubernetes\" >> /logs/app.log; sleep 2; done"
        ],
        "volumeMounts": [
          {
            "name": "logs",
            "mountPath": "/logs"
          }
        ]
      }
    ],
    "initContainers": [
      {
        "name": "log-reader",
        "image": "busybox:1.37.0",
        "restartPolicy": "Always",
        "command": [
          "sh",
          "-c",
          "touch /logs/app.log; tail -n+1 -F /logs/app.log"
        ],
        "volumeMounts": [
          {
            "name": "logs",
            "mountPath": "/logs"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "logs",
        "emptyDir": {}
      }
    ]
  }
}
YAML
ready_pod book-cka-pods log-demo
sleep 3
kubectl -n book-cka-pods logs log-demo -c log-reader --tail=3
