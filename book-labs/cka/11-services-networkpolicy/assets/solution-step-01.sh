#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-11-services-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": "web",
    "namespace": "book-cka-services"
  },
  "spec": {
    "selector": {
      "app": "web"
    },
    "ports": [
      {
        "port": 80,
        "targetPort": "http"
      }
    ]
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": "node-web",
    "namespace": "book-cka-services"
  },
  "spec": {
    "selector": {
      "app": "web"
    },
    "ports": [
      {
        "port": 80,
        "targetPort": "http",
        "nodePort": 31815
      }
    ],
    "type": "NodePort"
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": "public-web",
    "namespace": "book-cka-services"
  },
  "spec": {
    "selector": {
      "app": "web"
    },
    "ports": [
      {
        "port": 80,
        "targetPort": "http"
      }
    ],
    "type": "LoadBalancer"
  }
}
---
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": "web-alt",
    "namespace": "book-cka-services"
  },
  "spec": {
    "selector": {
      "app": "web"
    },
    "ports": [
      {
        "port": 3231,
        "targetPort": "http"
      }
    ]
  }
}
YAML

NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
wait_until 30 kubectl -n book-cka-services exec client -- wget -qO- -T 3 http://web
wait_until 30 kubectl -n book-cka-services exec client -- wget -qO- -T 3 "http://$NODE_IP:31815"
wait_until 30 kubectl -n book-cka-services exec client -- wget -qO- -T 3 http://web-alt:3231
external=$(kubectl -n book-cka-services get svc public-web -o jsonpath='{.status.loadBalancer.ingress}')
if [[ -z "$external" ]]; then printf 'Pending: no external load balancer implementation is installed in this VM.\n' > "$WORK_DIR/loadbalancer-status.txt"; else printf '%s\n' "$external" > "$WORK_DIR/loadbalancer-status.txt"; fi
