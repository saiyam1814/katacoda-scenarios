#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-13-helm-certificates
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
source "$(dirname -- "${BASH_SOURCE[0]}")/helm.sh"
ensure_helm

reset_ns book-cka-certificates
if "$HELM" status book-cert-manager -n book-cka-cert-manager >/dev/null 2>&1; then "$HELM" uninstall book-cert-manager -n book-cka-cert-manager --wait; fi
kubectl delete namespace book-cka-cert-manager --ignore-not-found
if kubectl get crd certificates.cert-manager.io >/dev/null 2>&1; then fail 'Use a fresh VM without another cert-manager installation'; fi
"$HELM" repo add jetstack https://charts.jetstack.io --force-update
"$HELM" repo update jetstack
rm -f "$WORK_DIR/cert-manager-rendered.yaml" "$WORK_DIR/certificate.pem"
setup_done
