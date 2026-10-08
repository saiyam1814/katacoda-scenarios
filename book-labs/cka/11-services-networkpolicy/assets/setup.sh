#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-11-services-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
source "$(dirname -- "${BASH_SOURCE[0]}")/network.sh"

for namespace in book-cka-services book-cka-policy book-cka-frontend book-cka-other; do reset_ns "$namespace"; done
kubectl label namespace book-cka-frontend book-labs.example/team=frontend --overwrite
rm -f "$WORK_DIR/loadbalancer-status.txt"
kubectl apply -f - <<'YAML'
{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": "web",
    "namespace": "book-cka-services"
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
            ]
          }
        ]
      }
    }
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "client",
    "namespace": "book-cka-services",
    "labels": {
      "role": "allowed"
    }
  },
  "spec": {
    "containers": [
      {
        "name": "client",
        "image": "busybox:1.37.0",
        "command": [
          "sleep",
          "3600"
        ]
      }
    ]
  }
}
YAML
kubectl apply -f - <<'YAML'
{
  "apiVersion": "v1",
  "kind": "ConfigMap",
  "metadata": {
    "name": "nginx-config",
    "namespace": "book-cka-policy"
  },
  "data": {
    "default.conf": "server { listen 80; listen 8080; location / { return 200 \"book-network\\n\"; } }\n"
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "backend",
    "namespace": "book-cka-policy",
    "labels": {
      "app": "backend"
    }
  },
  "spec": {
    "containers": [
      {
        "name": "web",
        "image": "nginx:1.28.0",
        "ports": [
          {
            "containerPort": 80
          },
          {
            "containerPort": 8080
          }
        ],
        "volumeMounts": [
          {
            "name": "config",
            "mountPath": "/etc/nginx/conf.d"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "config",
        "configMap": {
          "name": "nginx-config"
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
    "name": "trusted",
    "namespace": "book-cka-frontend",
    "labels": {
      "role": "allowed"
    }
  },
  "spec": {
    "containers": [
      {
        "name": "client",
        "image": "busybox:1.37.0",
        "command": [
          "sleep",
          "3600"
        ]
      }
    ]
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "wrong-label",
    "namespace": "book-cka-frontend",
    "labels": {
      "role": "other"
    }
  },
  "spec": {
    "containers": [
      {
        "name": "client",
        "image": "busybox:1.37.0",
        "command": [
          "sleep",
          "3600"
        ]
      }
    ]
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "trusted",
    "namespace": "book-cka-other",
    "labels": {
      "role": "allowed"
    }
  },
  "spec": {
    "containers": [
      {
        "name": "client",
        "image": "busybox:1.37.0",
        "command": [
          "sleep",
          "3600"
        ]
      }
    ]
  }
}
YAML

ready_deploy book-cka-services web
ready_pod book-cka-services client
ready_pod book-cka-policy backend
ready_pod book-cka-frontend trusted
ready_pod book-cka-frontend wrong-label
ready_pod book-cka-other trusted
IP=$(network_target)
http_ok book-cka-frontend trusted "http://$IP:8080"
kubectl -n book-cka-policy apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: setup-enforcement-check
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes: [Ingress]
YAML
for attempt in $(seq 1 10); do blocked book-cka-frontend trusted "http://$IP" && break; sleep 1; done
blocked book-cka-frontend trusted "http://$IP" || fail 'The CNI is not enforcing NetworkPolicy; use the advertised hosted cluster'
kubectl -n book-cka-policy delete networkpolicy setup-enforcement-check
wait_until 30 http_ok book-cka-frontend trusted "http://$IP"
setup_done
