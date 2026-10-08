#!/usr/bin/env bash
LAB_ID=infra-02-cluster-upgrade
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
kubectl drain node01 --ignore-daemonsets --timeout=180s
timeout 360 ssh -o BatchMode=yes -o ConnectTimeout=5 node01 bash -s -- upgrade-kubeadm 1.35 1.35.9 < "$ASSET_DIR/node-packages.sh"
timeout 180 ssh -o BatchMode=yes -o ConnectTimeout=5 node01 kubeadm upgrade node
timeout 240 ssh -o BatchMode=yes -o ConnectTimeout=5 node01 bash -s -- upgrade-kubelet < "$ASSET_DIR/node-packages.sh"
k uncordon node01
kubectl wait --for=condition=Ready node/node01 --timeout=180s
kubectl wait --for=jsonpath='{.status.nodeInfo.kubeletVersion}'=v1.35.9 node/node01 --timeout=180s
kubectl -n upgrade-check rollout status deployment/web --timeout=180s
k get nodes -o custom-columns=NAME:.metadata.name,VERSION:.status.nodeInfo.kubeletVersion > /tmp/cka10-versions.txt
# A restarted kubelet can briefly disrupt API/exec after its Ready status.
# Wait here for real behavior to settle; keep the browser CHECK fast.
deadline=$((SECONDS + 180))
until bash "$ASSET_DIR/verify2.sh" > "$STATE_DIR/upgrade2-check.log" 2>&1; do
  if (( SECONDS >= deadline )); then cat "$STATE_DIR/upgrade2-check.log" >&2; exit 1; fi
  sleep 2
done
cat "$STATE_DIR/upgrade2-check.log"
