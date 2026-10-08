#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-13-helm-certificates
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl get crd certificates.cert-manager.io -o jsonpath='{.spec.versions[?(@.name=="v1")].schema.openAPIV3Schema.properties.spec.properties.dnsNames}' > "$WORK_DIR/dnsnames-schema.json"
kubectl apply -f - <<'YAML'
{
  "apiVersion": "cert-manager.io/v1",
  "kind": "Issuer",
  "metadata": {
    "name": "lab-selfsigned",
    "namespace": "book-cka-certificates"
  },
  "spec": {
    "selfSigned": {}
  }
}
---
{
  "apiVersion": "cert-manager.io/v1",
  "kind": "Certificate",
  "metadata": {
    "name": "app",
    "namespace": "book-cka-certificates"
  },
  "spec": {
    "secretName": "app-tls",
    "dnsNames": [
      "app.cka.lab"
    ],
    "issuerRef": {
      "name": "lab-selfsigned",
      "kind": "Issuer"
    }
  }
}
---
{
  "apiVersion": "cert-manager.io/v1",
  "kind": "Certificate",
  "metadata": {
    "name": "missing-issuer",
    "namespace": "book-cka-certificates"
  },
  "spec": {
    "secretName": "missing-tls",
    "dnsNames": [
      "missing.cka.lab"
    ],
    "issuerRef": {
      "name": "absent",
      "kind": "Issuer"
    }
  }
}
YAML

kubectl -n book-cka-certificates wait --for=condition=Ready issuer/lab-selfsigned certificate/app --timeout=120s
kubectl -n book-cka-certificates get secret app-tls -o jsonpath='{.data.tls\.crt}' | base64 --decode > "$WORK_DIR/certificate.pem"
openssl x509 -in "$WORK_DIR/certificate.pem" -noout -subject -issuer -ext subjectAltName
for attempt in $(seq 1 45); do
 ready=$(kubectl -n book-cka-certificates get certificate missing-issuer -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
 [[ "$ready" == False ]] && break
 sleep 2
done
