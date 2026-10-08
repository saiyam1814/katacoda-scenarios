#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-08-static-pods-logs
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
node_exec() { if [[ -n ${BOOK_LAB_NODE_CONTAINER:-} ]]; then docker exec -i "$BOOK_LAB_NODE_CONTAINER" "$@"; else sudo "$@"; fi; }

if test -f "$WORK_DIR/static-dir.txt"; then node_exec rm -f "$(cat "$WORK_DIR/static-dir.txt")/book-cka-static.yaml"; fi
kubectl delete namespace book-cka-hostpods --ignore-not-found
rm -f "$STATE_DIR/ready"
