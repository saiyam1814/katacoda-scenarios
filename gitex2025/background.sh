#!/bin/bash
# Wait until Kubernetes control plane is responsive
until kubectl version &>/dev/null; do sleep 1; done
# Ensure all nodes are Ready
kubectl wait --for=condition=Ready node --all --timeout=60s

# Export environment host variables for convenience (if needed)
HOST_DOMAIN="[[HOST_SUBDOMAIN]]-30080-[[KATACODA_HOST]].environments.katacoda.com"
ARGOCD_DOMAIN="[[HOST_SUBDOMAIN]]-30443-[[KATACODA_HOST]].environments.katacoda.com"
echo "export HOST_DOMAIN=${HOST_DOMAIN}" >> ~/.bashrc
echo "export ARGOCD_DOMAIN=${ARGOCD_DOMAIN}" >> ~/.bashrc
