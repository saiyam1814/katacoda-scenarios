#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-09-metrics-autoscaling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
source "$(dirname -- "${BASH_SOURCE[0]}")/metrics.sh"

reset_ns book-cka-metrics
reset_ns book-cka-hpa
rm -f "$WORK_DIR/highest-memory.txt" "$WORK_DIR/hpa-scaled.json"
metrics_prepare
metrics_overlay
kubectl apply -f - <<'YAML'
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "memory-user",
    "namespace": "book-cka-metrics"
  },
  "spec": {
    "containers": [
      {
        "name": "memory",
        "image": "python:3.13-alpine",
        "command": [
          "python3",
          "-c",
          "import time; data=bytearray(48*1024*1024); time.sleep(3600)"
        ],
        "resources": {
          "requests": {
            "cpu": "10m",
            "memory": "64Mi"
          },
          "limits": {
            "memory": "96Mi"
          }
        }
      }
    ]
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "small",
    "namespace": "book-cka-metrics"
  },
  "spec": {
    "containers": [
      {
        "name": "small",
        "image": "busybox:1.37.0",
        "command": [
          "sleep",
          "3600"
        ],
        "resources": {
          "requests": {
            "cpu": "10m",
            "memory": "8Mi"
          },
          "limits": {
            "memory": "16Mi"
          }
        }
      }
    ]
  }
}
YAML

ready_pod book-cka-metrics memory-user
ready_pod book-cka-metrics small
for attempt in $(seq 1 60); do
 count=$(kubectl -n book-cka-metrics top pods --no-headers 2>/dev/null | wc -l | tr -d ' ') || count=0
 [[ "$count" == 2 ]] && break
 sleep 2
done
[[ "$count" == 2 ]] || fail 'Waited for metrics samples from both ranking Pods'
setup_done
