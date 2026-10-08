#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-14-gateway-ingress
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/helm.sh"
ensure_helm

kubectl delete namespace book-cka-routing --ignore-not-found
kubectl delete gatewayclass lab-gateway --ignore-not-found
"$HELM" uninstall book-traefik -n book-cka-traefik --wait
kubectl delete namespace book-cka-traefik --ignore-not-found
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml --ignore-not-found
rm -f "$WORK_DIR/web.key" "$WORK_DIR/web.crt"
rm -f "$STATE_DIR/ready"
