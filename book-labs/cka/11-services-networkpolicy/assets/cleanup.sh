#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-11-services-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
kubectl delete namespace book-cka-services book-cka-policy book-cka-frontend book-cka-other --ignore-not-found
rm -f "$STATE_DIR/ready"
