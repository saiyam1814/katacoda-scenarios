#!/usr/bin/env bash
LAB_ID=infra-02-cluster-upgrade
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
bash "$ASSET_DIR/node-packages.sh" upgrade-kubeadm 1.35 1.35.9
kubeadm upgrade plan
kubeadm upgrade apply v1.35.9 --yes
kubectl drain controlplane --ignore-daemonsets --timeout=180s
bash "$ASSET_DIR/node-packages.sh" upgrade-kubelet
kubectl wait --for=condition=Ready node/controlplane --timeout=180s
kubectl wait --for=jsonpath='{.status.nodeInfo.kubeletVersion}'=v1.35.9 node/controlplane --timeout=180s
k uncordon controlplane
# A restarted kubelet can briefly disrupt API/exec after its Ready status.
# Wait here for real behavior to settle; keep the browser CHECK fast.
deadline=$((SECONDS + 180))
until bash "$ASSET_DIR/verify1.sh" > "$STATE_DIR/upgrade1-check.log" 2>&1; do
  if (( SECONDS >= deadline )); then cat "$STATE_DIR/upgrade1-check.log" >&2; exit 1; fi
  sleep 2
done
cat "$STATE_DIR/upgrade1-check.log"
