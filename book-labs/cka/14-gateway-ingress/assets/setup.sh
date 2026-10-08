#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-14-gateway-ingress
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
source "$(dirname -- "${BASH_SOURCE[0]}")/helm.sh"
ensure_helm

reset_ns book-cka-routing
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
"$HELM" repo add book-traefik https://traefik.github.io/charts --force-update
"$HELM" repo update book-traefik
cat > "$WORK_DIR/traefik-values.yaml" <<'YAML'
providers:
  kubernetesGateway:
    enabled: true
    statusAddress:
      service:
        enabled: false
  kubernetesIngress:
    enabled: true
    publishedService:
      enabled: false
gateway:
  enabled: false
gatewayClass:
  enabled: false
ingressClass:
  enabled: true
  isDefaultClass: false
  name: lab-ingress
service:
  type: ClusterIP
ports:
  web:
    port: 80
securityContext:
  capabilities:
    drop: [ALL]
    add: [NET_BIND_SERVICE]
tolerations:
- operator: Exists
YAML
"$HELM" upgrade --install book-traefik book-traefik/traefik --version 41.6.1 --namespace book-cka-traefik --create-namespace -f "$WORK_DIR/traefik-values.yaml" --wait --timeout 5m
IP=$(kubectl -n book-cka-traefik get svc book-traefik -o jsonpath='{.spec.clusterIP}')
"$HELM" upgrade book-traefik book-traefik/traefik --version 41.6.1 -n book-cka-traefik --reuse-values --set "providers.kubernetesGateway.statusAddress.ip=$IP" --set "providers.kubernetesIngress.ingressEndpoint.ip=$IP" --wait --timeout 5m
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: lab-gateway
spec:
  controllerName: traefik.io/gateway-controller
YAML
kubectl wait --for=condition=Accepted gatewayclass/lab-gateway --timeout=120s
openssl req -x509 -nodes -newkey rsa:2048 -days 2 -keyout "$WORK_DIR/web.key" -out "$WORK_DIR/web.crt" -subj '/CN=web.cka.lab' -addext 'subjectAltName=DNS:web.cka.lab'
kubectl -n book-cka-routing create configmap training-ca --from-file=ca.crt="$WORK_DIR/web.crt"
kubectl apply -f - <<'YAML'
{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": "web-gateway",
    "namespace": "book-cka-routing"
  },
  "spec": {
    "replicas": 2,
    "selector": {
      "matchLabels": {
        "app": "web-gateway"
      }
    },
    "template": {
      "metadata": {
        "labels": {
          "app": "web-gateway"
        }
      },
      "spec": {
        "containers": [
          {
            "name": "web",
            "image": "nginx:1.28.0"
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
    "name": "web-gateway",
    "namespace": "book-cka-routing"
  },
  "spec": {
    "selector": {
      "app": "web-gateway"
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
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": "web-ingress",
    "namespace": "book-cka-routing"
  },
  "spec": {
    "replicas": 2,
    "selector": {
      "matchLabels": {
        "app": "web-ingress"
      }
    },
    "template": {
      "metadata": {
        "labels": {
          "app": "web-ingress"
        }
      },
      "spec": {
        "containers": [
          {
            "name": "web",
            "image": "nginx:1.28.0"
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
    "name": "web-ingress",
    "namespace": "book-cka-routing"
  },
  "spec": {
    "selector": {
      "app": "web-ingress"
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
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "client",
    "namespace": "book-cka-routing"
  },
  "spec": {
    "containers": [
      {
        "name": "client",
        "image": "curlimages/curl:8.16.0",
        "command": [
          "sleep",
          "3600"
        ],
        "volumeMounts": [
          {
            "name": "trust",
            "mountPath": "/trust",
            "readOnly": true
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "trust",
        "configMap": {
          "name": "training-ca"
        }
      }
    ]
  }
}
YAML

ready_deploy book-cka-routing web-gateway
ready_deploy book-cka-routing web-ingress
ready_pod book-cka-routing client
rm -f "$WORK_DIR/unresolved-route.json"
setup_done
