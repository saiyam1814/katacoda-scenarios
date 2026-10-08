#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-01-rbac
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
kubectl delete namespace book-cka-rbac --ignore-not-found
kubectl delete clusterrole book-cka-creators --ignore-not-found
rm -f "$STATE_DIR/ready"
