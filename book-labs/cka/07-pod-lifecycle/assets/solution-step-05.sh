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
    "name": "shared",
    "namespace": "book-cka-pods"
  },
  "spec": {
    "containers": [
      {
        "name": "c1",
        "image": "busybox:1.37.0",
        "command": [
          "sh",
          "-c",
          "printf \"Hello from c1 container.\\n\" >/work/c1.txt"
        ],
        "volumeMounts": [
          {
            "name": "work",
            "mountPath": "/work"
          }
        ]
      },
      {
        "name": "c2",
        "image": "busybox:1.37.0",
        "command": [
          "sh",
          "-c",
          "printf \"Hello from c2 container.\\n\" >/work/c2.txt"
        ],
        "volumeMounts": [
          {
            "name": "work",
            "mountPath": "/work"
          }
        ]
      },
      {
        "name": "c3",
        "image": "busybox:1.37.0",
        "command": [
          "sh",
          "-c",
          "for i in $(seq 1 60); do if test -s /work/c1.txt && test -s /work/c2.txt; then cat /work/c1.txt /work/c2.txt; exit 0; fi; sleep 1; done; exit 1"
        ],
        "volumeMounts": [
          {
            "name": "work",
            "mountPath": "/work"
          }
        ]
      }
    ],
    "restartPolicy": "Never",
    "volumes": [
      {
        "name": "work",
        "emptyDir": {}
      }
    ]
  }
}
YAML
for i in $(seq 1 60); do test "$(kubectl -n book-cka-pods get pod shared -o jsonpath='{.status.phase}')" = Succeeded && break; sleep 2; done
kubectl -n book-cka-pods logs shared -c c3
