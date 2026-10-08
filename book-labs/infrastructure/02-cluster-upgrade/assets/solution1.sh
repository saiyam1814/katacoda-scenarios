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
k uncordon controlplane
bash "$ASSET_DIR/verify1.sh"
