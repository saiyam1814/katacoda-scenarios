#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

kubectl create namespace build-room --dry-run=client -o yaml | kubectl apply -f -

touch /tmp/.cnpe-setup-done
