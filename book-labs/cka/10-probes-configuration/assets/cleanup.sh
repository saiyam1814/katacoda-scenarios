#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-10-probes-configuration
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
kubectl delete namespace book-cka-config book-cka-probes --ignore-not-found
if test -f "$WORK_DIR/node.txt"; then
 NODE=$(cat "$WORK_DIR/node.txt")
 kubectl taint node "$NODE" book-labs.example/pool=apps:NoSchedule-
 kubectl label node "$NODE" book-labs.example/pool-
fi
rm -f "$STATE_DIR/ready"
