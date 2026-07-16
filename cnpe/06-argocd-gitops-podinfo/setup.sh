#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

ARGOCD_VERSION=v3.2.6

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

# argocd CLI
ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && ARCH=arm64; [ "$ARCH" = "x86_64" ] && ARCH=amd64
curl -sL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${ARCH}"
chmod +x /usr/local/bin/argocd

kubectl -n argocd rollout status deploy/argocd-repo-server --timeout=600s || true
kubectl -n argocd rollout status deploy/argocd-server --timeout=600s || true
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=600s || true

touch /tmp/.cnpe-setup-done
