#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-09-metrics-autoscaling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": "cpu-app",
    "namespace": "book-cka-hpa"
  },
  "spec": {
    "replicas": 1,
    "selector": {
      "matchLabels": {
        "app": "cpu-app"
      }
    },
    "template": {
      "metadata": {
        "labels": {
          "app": "cpu-app"
        }
      },
      "spec": {
        "containers": [
          {
            "name": "web",
            "image": "registry.k8s.io/hpa-example",
            "resources": {
              "requests": {
                "cpu": "200m",
                "memory": "32Mi"
              },
              "limits": {
                "cpu": "500m",
                "memory": "128Mi"
              }
            }
          }
        ]
      }
    }
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": "cpu-app",
    "namespace": "book-cka-hpa"
  },
  "spec": {
    "selector": {
      "app": "cpu-app"
    },
    "ports": [
      {
        "port": 80,
        "targetPort": 80
      }
    ]
  }
}
---
{
  "apiVersion": "autoscaling/v2",
  "kind": "HorizontalPodAutoscaler",
  "metadata": {
    "name": "cpu-app",
    "namespace": "book-cka-hpa"
  },
  "spec": {
    "scaleTargetRef": {
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "name": "cpu-app"
    },
    "minReplicas": 1,
    "maxReplicas": 5,
    "metrics": [
      {
        "type": "Resource",
        "resource": {
          "name": "cpu",
          "target": {
            "type": "Utilization",
            "averageUtilization": 50
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
    "name": "load",
    "namespace": "book-cka-hpa"
  },
  "spec": {
    "containers": [
      {
        "name": "load",
        "image": "busybox:1.37.0",
        "command": [
          "sh",
          "-c",
          "while true; do wget -q -O- http://cpu-app >/dev/null; done"
        ],
        "resources": {
          "requests": {
            "cpu": "10m",
            "memory": "8Mi"
          },
          "limits": {
            "cpu": "100m",
            "memory": "32Mi"
          }
        }
      }
    ]
  }
}
YAML

ready_pod book-cka-hpa load
for attempt in $(seq 1 150); do
 count=$(kubectl -n book-cka-hpa get hpa cpu-app -o jsonpath='{.status.currentReplicas}')
 [[ ${count:-0} -ge 2 ]] && break
 sleep 2
done
[[ ${count:-0} -ge 2 ]] || fail 'The real HPA did not scale out; inspect metrics and the load Pod'
ready_deploy book-cka-hpa cpu-app
kubectl -n book-cka-hpa get hpa cpu-app -o json > "$WORK_DIR/hpa-scaled.json"
