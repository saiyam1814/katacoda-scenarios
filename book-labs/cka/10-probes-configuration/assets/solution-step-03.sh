#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-10-probes-configuration
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
{
  "apiVersion": "v1",
  "kind": "LimitRange",
  "metadata": {
    "name": "container-limits",
    "namespace": "book-cka-probes"
  },
  "spec": {
    "limits": [
      {
        "type": "Container",
        "max": {
          "memory": "256Mi"
        },
        "default": {
          "memory": "128Mi"
        },
        "defaultRequest": {
          "memory": "64Mi"
        }
      }
    ]
  }
}
---
{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": "web",
    "namespace": "book-cka-probes"
  },
  "spec": {
    "replicas": 2,
    "selector": {
      "matchLabels": {
        "app": "web"
      }
    },
    "template": {
      "metadata": {
        "labels": {
          "app": "web"
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
            "resources": {
              "requests": {
                "cpu": "100m",
                "memory": "64Mi"
              },
              "limits": {
                "cpu": "300m",
                "memory": "128Mi"
              }
            },
            "startupProbe": {
              "httpGet": {
                "path": "/",
                "port": "http"
              },
              "periodSeconds": 2,
              "failureThreshold": 30
            },
            "readinessProbe": {
              "httpGet": {
                "path": "/",
                "port": "http"
              },
              "periodSeconds": 3,
              "failureThreshold": 3
            },
            "livenessProbe": {
              "httpGet": {
                "path": "/",
                "port": "http"
              },
              "periodSeconds": 5,
              "failureThreshold": 3
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
        ],
        "affinity": {
          "nodeAffinity": {
            "requiredDuringSchedulingIgnoredDuringExecution": {
              "nodeSelectorTerms": [
                {
                  "matchExpressions": [
                    {
                      "key": "book-labs.example/pool",
                      "operator": "In",
                      "values": [
                        "apps"
                      ]
                    }
                  ]
                }
              ]
            }
          }
        }
      }
    }
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": "web",
    "namespace": "book-cka-probes"
  },
  "spec": {
    "selector": {
      "app": "web"
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

ready_deploy book-cka-probes web
