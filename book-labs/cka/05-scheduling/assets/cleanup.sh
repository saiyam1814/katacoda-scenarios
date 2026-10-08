#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
kubectl delete namespace book-cka-scheduling --ignore-not-found
if test -f "$WORK_DIR/node.txt"; then kubectl label node "$(cat "$WORK_DIR/node.txt")" book-labs.example/disk-; fi
rm -f "$STATE_DIR/ready"
