#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

KYVERNO_VERSION=v1.13.6

kubectl create namespace kyverno --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/install.yaml" --server-side

kubectl -n kyverno rollout status deploy/kyverno-admission-controller --timeout=600s || true
kubectl -n kyverno rollout status deploy/kyverno-background-controller --timeout=600s || true

kubectl create namespace policy-sandbox --dry-run=client -o yaml | kubectl apply -f -

touch /tmp/.cnpe-setup-done
