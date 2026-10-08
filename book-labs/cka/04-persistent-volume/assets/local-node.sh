node_exec() { if [[ -n ${BOOK_LAB_NODE_CONTAINER:-} ]]; then docker exec -i "$BOOK_LAB_NODE_CONTAINER" "$@"; else sudo "$@"; fi; }
