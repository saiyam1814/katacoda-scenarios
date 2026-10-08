#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-13-helm-certificates
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
source "$(dirname -- "${BASH_SOURCE[0]}")/helm.sh"
ensure_helm

"$HELM" template book-cert-manager jetstack/cert-manager --version v1.20.4 --namespace book-cka-cert-manager --set crds.enabled=true --set replicaCount=1 --include-crds > "$WORK_DIR/cert-manager-rendered.yaml"
"$HELM" install book-cert-manager jetstack/cert-manager --version v1.20.4 --namespace book-cka-cert-manager --create-namespace --set crds.enabled=true --set replicaCount=1 --wait --timeout 5m
"$HELM" upgrade book-cert-manager jetstack/cert-manager --version v1.20.4 --namespace book-cka-cert-manager --reuse-values --set replicaCount=2 --wait --timeout 5m
"$HELM" rollback book-cert-manager 1 --namespace book-cka-cert-manager --wait --timeout 5m
"$HELM" history book-cert-manager -n book-cka-cert-manager
