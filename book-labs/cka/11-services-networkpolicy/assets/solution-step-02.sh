#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-11-services-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
{
  "apiVersion": "networking.k8s.io/v1",
  "kind": "NetworkPolicy",
  "metadata": {
    "name": "default-deny",
    "namespace": "book-cka-policy"
  },
  "spec": {
    "podSelector": {},
    "policyTypes": [
      "Ingress"
    ]
  }
}
---
{
  "apiVersion": "networking.k8s.io/v1",
  "kind": "NetworkPolicy",
  "metadata": {
    "name": "frontend-only",
    "namespace": "book-cka-policy"
  },
  "spec": {
    "podSelector": {},
    "policyTypes": [
      "Ingress"
    ],
    "ingress": [
      {
        "from": [
          {
            "namespaceSelector": {
              "matchLabels": {
                "book-labs.example/team": "frontend"
              }
            },
            "podSelector": {
              "matchLabels": {
                "role": "allowed"
              }
            }
          }
        ],
        "ports": [
          {
            "protocol": "TCP",
            "port": 80
          }
        ]
      }
    ]
  }
}
YAML
source "$(dirname -- "${BASH_SOURCE[0]}")/network.sh"

IP=$(network_target)
wait_until 30 http_ok book-cka-frontend trusted "http://$IP"
for attempt in $(seq 1 10); do blocked book-cka-frontend trusted "http://$IP:8080" && break; sleep 1; done
