#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-10-probes-configuration
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "unready",
    "namespace": "book-cka-probes",
    "labels": {
      "app": "unready"
    }
  },
  "spec": {
    "containers": [
      {
        "name": "web",
        "image": "nginx:1.28.0",
        "ports": [
          {
            "name": "http",
            "containerPort": 80
          }
        ],
        "readinessProbe": {
          "httpGet": {
            "path": "/missing",
            "port": "http"
          },
          "periodSeconds": 2
        }
      }
    ],
    "tolerations": [
      {
        "key": "book-labs.example/pool",
        "operator": "Equal",
        "value": "apps",
        "effect": "NoSchedule"
      }
    ]
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": "unready",
    "namespace": "book-cka-probes"
  },
  "spec": {
    "selector": {
      "app": "unready"
    },
    "ports": [
      {
        "port": 80,
        "targetPort": 80
      }
    ]
  }
}
YAML

for i in $(seq 1 60); do
 phase=$(kubectl -n book-cka-probes get pod unready -o jsonpath='{.status.phase}')
 [[ "$phase" == Running ]] && break
 sleep 2
done
sleep 5
