#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-13-helm-certificates
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
cat "$WORK_DIR/dnsnames-schema.json" | json_assert 'd["type"]=="array" and d["items"]["type"]=="string"' 'Inspect and save the DNS-name schema field'
kubectl -n book-cka-certificates get certificate app -o json | json_assert 'd["spec"]["secretName"]=="app-tls" and "app.cka.lab" in d["spec"]["dnsNames"] and any(c["type"]=="Ready" and c["status"]=="True" for c in d["status"]["conditions"]) and [c for c in d["status"]["conditions"] if c["type"]=="Ready"][0].get("observedGeneration")==d["metadata"]["generation"]' 'Require current successful certificate reconciliation'
kubectl -n book-cka-certificates get secret app-tls -o json | json_assert 'd["type"]=="kubernetes.io/tls" and d["data"]["tls.crt"] and d["data"]["tls.key"]' 'The operator must issue a TLS Secret'
openssl x509 -in "$WORK_DIR/certificate.pem" -noout -ext subjectAltName | grep -q 'DNS:app.cka.lab' || fail 'Save the public certificate with the correct SAN'
kubectl -n book-cka-certificates get certificate missing-issuer -o json | json_assert 'd["spec"]["issuerRef"]["name"]=="absent" and any(c["type"]=="Ready" and c["status"]=="False" for c in d["status"]["conditions"])' 'The missing issuer must remain an actual failed reconciliation'
[[ -z $(kubectl -n book-cka-certificates get secret missing-tls --ignore-not-found -o name) ]] || fail 'A missing issuer must not issue a certificate'
pass "Step 2: Create and diagnose custom resources"
