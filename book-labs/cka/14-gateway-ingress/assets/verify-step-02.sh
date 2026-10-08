#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-14-gateway-ingress
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
source "$(dirname -- "${BASH_SOURCE[0]}")/routing.sh"

kubectl -n book-cka-routing get ingress web -o json | json_assert 'd["spec"]["ingressClassName"]=="lab-ingress" and d["spec"]["tls"][0]["hosts"]==["web.cka.lab"] and d["spec"]["tls"][0]["secretName"]=="web-tls" and d["spec"]["rules"][0]["host"]=="web.cka.lab"' 'Require the requested standard Ingress and TLS Secret reference'
kubectl -n book-cka-routing get secret web-tls -o json | json_assert 'd["type"]=="kubernetes.io/tls" and d["data"]["tls.crt"] and d["data"]["tls.key"]' 'Require a TLS Secret'
ingress_ok || fail 'HTTPS must succeed with the explicit CA trust and correct hostname, without -k'
report=$(openssl x509 -in "$WORK_DIR/web.crt" -noout -checkhost wrong.cka.lab 2>&1 || true)
printf '%s\n' "$report" | grep -q 'does NOT match' || fail 'Certificate identity must reject the wrong hostname'
pass "Step 2: Expose HTTPS with a verified certificate"
