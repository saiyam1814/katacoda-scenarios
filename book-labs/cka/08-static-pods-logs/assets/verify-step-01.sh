#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-08-static-pods-logs
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
node_exec() { if [[ -n ${BOOK_LAB_NODE_CONTAINER:-} ]]; then docker exec -i "$BOOK_LAB_NODE_CONTAINER" "$@"; else sudo "$@"; fi; }

STATIC_DIR=$(cat "$WORK_DIR/static-dir.txt")
node_exec test -s "$STATIC_DIR/book-cka-static.yaml" || fail 'Static manifest is absent on the node'
NODE=$(first_node)
assert_pod_ready book-cka-hostpods "book-cka-static-$NODE"
kubectl -n book-cka-hostpods get pod "book-cka-static-$NODE" -o json | json_assert 'd["metadata"].get("annotations",{}).get("kubernetes.io/config.mirror") and d["spec"]["containers"][0]["image"]=="nginx:1.28.0"' 'Require a kubelet-managed mirror Pod'
pass "Step 1: Create a real static Pod"
