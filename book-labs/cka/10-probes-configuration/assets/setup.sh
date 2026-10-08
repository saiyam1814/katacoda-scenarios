#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-10-probes-configuration
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-config
reset_ns book-cka-probes
NODE=$(first_node)
printf '%s\n' "$NODE" > "$WORK_DIR/node.txt"
kubectl label node "$NODE" book-labs.example/pool=apps --overwrite
kubectl taint node "$NODE" book-labs.example/pool=apps:NoSchedule --overwrite
setup_done
