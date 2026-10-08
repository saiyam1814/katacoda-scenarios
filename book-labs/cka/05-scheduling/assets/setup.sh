#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-05-scheduling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-scheduling
NODE=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')
CONTROL=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
test -n "$NODE" && test -n "$CONTROL" || fail 'Use the advertised two-node cluster'
printf '%s\n' "$CONTROL" > "$WORK_DIR/control.txt"
if ! kubectl get node "$CONTROL" -o json | python3 -c 'import json,sys; assert any(t["key"]=="node-role.kubernetes.io/control-plane" and t["effect"]=="NoSchedule" for t in json.load(sys.stdin)["spec"].get("taints",[]))'; then kubectl taint node "$CONTROL" node-role.kubernetes.io/control-plane:NoSchedule; touch "$WORK_DIR/added-control-taint"; fi
printf '%s\n' "$NODE" > "$WORK_DIR/node.txt"
kubectl label node "$NODE" book-labs.example/disk=unconfigured --overwrite
kubectl -n book-cka-scheduling run reporter --image=busybox:1.37.0 --overrides='{"spec":{"nodeSelector":{"book-labs.example/disk":"missing"}}}' --command -- sleep 3600
setup_done
