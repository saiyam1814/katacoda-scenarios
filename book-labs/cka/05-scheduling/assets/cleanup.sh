#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
kubectl delete namespace book-cka-scheduling --ignore-not-found
if test -f "$WORK_DIR/node.txt"; then kubectl label node "$(cat "$WORK_DIR/node.txt")" book-labs.example/disk-; fi
if test -f "$WORK_DIR/added-control-taint"; then kubectl taint node "$(cat "$WORK_DIR/control.txt")" node-role.kubernetes.io/control-plane:NoSchedule-; rm -f "$WORK_DIR/added-control-taint"; fi
rm -f "$STATE_DIR/ready"
