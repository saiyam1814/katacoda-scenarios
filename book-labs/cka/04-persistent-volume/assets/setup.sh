#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-04-persistent-volume
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
source "$(dirname -- "${BASH_SOURCE[0]}")/local-node.sh"

reset_ns book-cka-storage
kubectl delete pv book-cka-local-data book-cka-local-retained --ignore-not-found
kubectl delete storageclass book-cka-local --ignore-not-found
first_node > "$WORK_DIR/node.txt"
node_exec mkdir -p /var/book-labs/cka-local/data /var/book-labs/cka-local/retained
printf 'local-volume-data\n' | node_exec tee /var/book-labs/cka-local/data/marker.txt
node_exec rm -f /var/book-labs/cka-local/retained/retained.txt
rm -f "$WORK_DIR/deleted-claim-uid.txt"
setup_done
