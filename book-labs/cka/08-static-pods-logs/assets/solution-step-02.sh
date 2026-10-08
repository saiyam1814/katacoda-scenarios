#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-08-static-pods-logs
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
NODE=$(first_node)
kubectl -n book-cka-hostpods get pod "book-cka-static-$NODE" -o jsonpath='{.metadata.uid}' > "$WORK_DIR/mirror-before.txt"
kubectl -n book-cka-hostpods delete pod "book-cka-static-$NODE" --wait=false
for i in $(seq 1 90); do
 current=$(kubectl -n book-cka-hostpods get pod "book-cka-static-$NODE" -o jsonpath='{.metadata.uid}' 2>/dev/null || true)
 if [[ -n "$current" && "$current" != "$(cat "$WORK_DIR/mirror-before.txt")" ]]; then break; fi
 sleep 2
done
ready_pod book-cka-hostpods "book-cka-static-$NODE"
