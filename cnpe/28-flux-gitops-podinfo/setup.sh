#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -euo pipefail
export KUBECONFIG=/root/.kube/config
kubectl wait --for=condition=Ready nodes --all --timeout=180s
FLUX_VERSION=2.9.0
ARCH=$(uname -m)
case "$ARCH" in aarch64|arm64) ARCH=arm64;; x86_64) ARCH=amd64;; esac
curl -fsSL "https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_${ARCH}.tar.gz" | tar xz -C /usr/local/bin flux
flux install --version="v${FLUX_VERSION}" --components=source-controller,helm-controller
kubectl -n flux-system rollout status deployment/source-controller --timeout=600s
kubectl -n flux-system rollout status deployment/helm-controller --timeout=600s
touch /tmp/.cnpe-setup-done
