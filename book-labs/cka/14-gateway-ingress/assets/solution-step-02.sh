#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-14-gateway-ingress
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-routing create secret tls web-tls --key="$WORK_DIR/web.key" --cert="$WORK_DIR/web.crt" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<'YAML'
{
  "apiVersion": "networking.k8s.io/v1",
  "kind": "Ingress",
  "metadata": {
    "name": "web",
    "namespace": "book-cka-routing"
  },
  "spec": {
    "ingressClassName": "lab-ingress",
    "tls": [
      {
        "hosts": [
          "web.cka.lab"
        ],
        "secretName": "web-tls"
      }
    ],
    "rules": [
      {
        "host": "web.cka.lab",
        "http": {
          "paths": [
            {
              "path": "/",
              "pathType": "Prefix",
              "backend": {
                "service": {
                  "name": "web-ingress",
                  "port": {
                    "number": 80
                  }
                }
              }
            }
          ]
        }
      }
    ]
  }
}
YAML
source "$(dirname -- "${BASH_SOURCE[0]}")/routing.sh"

wait_until 60 ingress_ok
openssl x509 -in "$WORK_DIR/web.crt" -noout -checkhost wrong.cka.lab || true
