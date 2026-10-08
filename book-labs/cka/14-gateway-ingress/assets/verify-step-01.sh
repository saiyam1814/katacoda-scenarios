#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-14-gateway-ingress
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
source "$(dirname -- "${BASH_SOURCE[0]}")/routing.sh"

route_current
kubectl -n book-cka-routing get gateway public-web -o json | json_assert 'd["spec"]["gatewayClassName"]=="lab-gateway" and d["spec"]["listeners"][0]["name"]=="http" and d["spec"]["listeners"][0]["port"]==80 and d["status"].get("addresses") and any(c["type"]=="Programmed" and c["status"]=="True" for c in d["status"]["conditions"])' 'Require a programmed Gateway with an actual reachable address'
gateway_ok || fail 'Gateway traffic must reach nginx'
IP=$(routing_ip)
code=$(kubectl -n book-cka-routing exec client -- curl -sS --max-time 4 -o /dev/null -w '%{http_code}' -H 'Host: wrong.cka.lab' "http://$IP/")
[[ "$code" -ge 400 ]] || fail 'An unmatched host must not route to the application'
uid=$(kubectl -n book-cka-routing get httproute shop -o jsonpath='{.metadata.uid}')
python3 - "$WORK_DIR/unresolved-route.json" "$uid" <<'PYBAD'
import json,sys
x=json.load(open(sys.argv[1]));assert x['metadata']['uid']==sys.argv[2] and x['spec']['rules'][0]['backendRefs'][0]['name']=='missing';assert any(c['type']=='ResolvedRefs' and c['status']=='False' and c.get('observedGeneration')==x['metadata']['generation'] for p in x['status']['parents'] for c in p['conditions'])
PYBAD
pass "Step 1: Create and diagnose Gateway API routes"
