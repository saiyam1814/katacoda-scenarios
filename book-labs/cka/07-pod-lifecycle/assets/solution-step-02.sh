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
    "name": "init-web",
    "namespace": "book-cka-pods"
  },
  "spec": {
    "containers": [
      {
        "name": "web",
        "image": "nginx:1.28.0",
        "volumeMounts": [
          {
            "name": "root",
            "mountPath": "/usr/share/nginx/html"
          }
        ]
      }
    ],
    "initContainers": [
      {
        "name": "sam-init",
        "image": "busybox:1.37.0",
        "command": [
          "sh",
          "-c",
          "printf \"hello world\\n\" > /work/index.html"
        ],
        "volumeMounts": [
          {
            "name": "root",
            "mountPath": "/work"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "root",
        "emptyDir": {}
      }
    ]
  }
}
YAML
ready_pod book-cka-pods init-web
kubectl -n book-cka-pods exec init-web -c web -- curl -fsS http://localhost
