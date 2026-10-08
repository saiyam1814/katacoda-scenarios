#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-10-probes-configuration
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-config create configmap demo --from-literal=colour=green --from-literal=name=saiyam --from-literal=exam=cka
kubectl -n book-cka-config create secret generic cka-demo --from-literal=password=training-only-password
kubectl apply -f - <<'YAML'
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "demo-pod",
    "namespace": "book-cka-config"
  },
  "spec": {
    "containers": [
      {
        "name": "app",
        "image": "busybox:1.37.0",
        "command": [
          "sleep",
          "3600"
        ],
        "envFrom": [
          {
            "configMapRef": {
              "name": "demo"
            }
          }
        ],
        "env": [
          {
            "name": "DATABASE_PASSWORD",
            "valueFrom": {
              "secretKeyRef": {
                "name": "cka-demo",
                "key": "password"
              }
            }
          }
        ],
        "volumeMounts": [
          {
            "name": "config",
            "mountPath": "/etc/config",
            "readOnly": true
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "config",
        "configMap": {
          "name": "demo"
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
YAML

ready_pod book-cka-config demo-pod
kubectl -n book-cka-config exec demo-pod -- sh -c 'test "$colour $name $exam" = "green saiyam cka" && test -n "$DATABASE_PASSWORD"'
