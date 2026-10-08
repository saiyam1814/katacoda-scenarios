#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-04-persistent-volume
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/local-node.sh"

kubectl delete namespace book-cka-storage --ignore-not-found
kubectl delete pv book-cka-local-data book-cka-local-retained --ignore-not-found
kubectl delete storageclass book-cka-local --ignore-not-found
node_exec rm -rf /var/book-labs/cka-local
rm -f "$STATE_DIR/ready"
