#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-08-static-pods-logs
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
node_exec() { if [[ -n ${BOOK_LAB_NODE_CONTAINER:-} ]]; then docker exec -i "$BOOK_LAB_NODE_CONTAINER" "$@"; else sudo "$@"; fi; }

cat > "$WORK_DIR/static.yaml" <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: book-cka-static, namespace: book-cka-hostpods}
spec:
  containers: [{name: web, image: 'nginx:1.28.0'}]
YAML
STATIC_DIR=$(cat "$WORK_DIR/static-dir.txt")
node_exec tee "$STATIC_DIR/book-cka-static.yaml" < "$WORK_DIR/static.yaml" >/dev/null
NODE=$(first_node)
for i in $(seq 1 60); do kubectl -n book-cka-hostpods get pod "book-cka-static-$NODE" >/dev/null 2>&1 && break; sleep 2; done
ready_pod book-cka-hostpods "book-cka-static-$NODE"
printf 'book-cka-static-%s\n' "$NODE" > "$WORK_DIR/mirror-name.txt"
