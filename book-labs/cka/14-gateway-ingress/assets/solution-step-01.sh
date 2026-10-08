#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-14-gateway-ingress
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
{
  "apiVersion": "gateway.networking.k8s.io/v1",
  "kind": "Gateway",
  "metadata": {
    "name": "public-web",
    "namespace": "book-cka-routing"
  },
  "spec": {
    "gatewayClassName": "lab-gateway",
    "listeners": [
      {
        "name": "http",
        "protocol": "HTTP",
        "port": 80,
        "hostname": "shop.cka.lab",
        "allowedRoutes": {
          "namespaces": {
            "from": "Same"
          }
        }
      }
    ]
  }
}
---
{
  "apiVersion": "gateway.networking.k8s.io/v1",
  "kind": "HTTPRoute",
  "metadata": {
    "name": "shop",
    "namespace": "book-cka-routing"
  },
  "spec": {
    "parentRefs": [
      {
        "name": "public-web",
        "sectionName": "http"
      }
    ],
    "hostnames": [
      "shop.cka.lab"
    ],
    "rules": [
      {
        "matches": [
          {
            "path": {
              "type": "PathPrefix",
              "value": "/"
            }
          }
        ],
        "backendRefs": [
          {
            "name": "web-gateway",
            "port": 80
          }
        ]
      }
    ]
  }
}
YAML
source "$(dirname -- "${BASH_SOURCE[0]}")/routing.sh"

kubectl -n book-cka-routing wait --for=condition=Programmed gateway/public-web --timeout=120s
wait_until 60 route_current
wait_until 30 gateway_ok
kubectl -n book-cka-routing patch httproute shop --type=json -p '[{"op":"replace","path":"/spec/rules/0/backendRefs/0/name","value":"missing"}]'
for attempt in $(seq 1 60); do
 kubectl -n book-cka-routing get httproute shop -o json > "$WORK_DIR/unresolved-route.json"
 if python3 - "$WORK_DIR/unresolved-route.json" <<'PYBAD'
import json,sys
x=json.load(open(sys.argv[1]));assert any(c['type']=='ResolvedRefs' and c['status']=='False' and c.get('observedGeneration')==x['metadata']['generation'] for p in x.get('status',{}).get('parents',[]) for c in p['conditions'])
PYBAD
 then break; fi
 sleep 2
done
kubectl -n book-cka-routing patch httproute shop --type=json -p '[{"op":"replace","path":"/spec/rules/0/backendRefs/0/name","value":"web-gateway"}]'
wait_until 60 route_current
wait_until 30 gateway_ok
