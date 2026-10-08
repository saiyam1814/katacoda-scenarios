#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-scheduling
NODE=$(first_node)
printf '%s\n' "$NODE" > "$WORK_DIR/node.txt"
kubectl label node "$NODE" book-labs.example/disk=ssd --overwrite
kubectl -n book-cka-scheduling run reporter --image=busybox:1.37.0 --overrides='{"spec":{"nodeSelector":{"book-labs.example/disk":"missing"}}}' --command -- sleep 3600
kubectl -n book-cka-scheduling run anchor --image=busybox:1.37.0 --labels=role=anchor --command -- sleep 3600
ready_pod book-cka-scheduling anchor
setup_done
