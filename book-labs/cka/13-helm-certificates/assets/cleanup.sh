#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-13-helm-certificates
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/helm.sh"
ensure_helm

kubectl delete namespace book-cka-certificates --ignore-not-found
"$HELM" uninstall book-cert-manager -n book-cka-cert-manager --wait
kubectl delete namespace book-cka-cert-manager --ignore-not-found
kubectl get crd -o name | awk '/\.cert-manager\.io$|\.acme\.cert-manager\.io$/' | xargs -r kubectl delete
rm -f "$STATE_DIR/ready"
