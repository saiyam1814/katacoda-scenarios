#!/bin/bash

# Background setup - runs while user reads the intro
echo "Setting up KubeCon EU 2026 workshop environment..."

# Create workspace
mkdir -p /root/workshop/{manifests,rag-app/documents}

# Create namespace
kubectl create namespace ai-workshop --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace=ai-workshop

# Pre-install numpy for vector RAG (saves ~30s during workshop)
pip3 install numpy --quiet --break-system-packages 2>/dev/null &

# Pre-download vCluster CLI
curl -L -o /usr/local/bin/vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.24.1/vcluster-linux-amd64" 2>/dev/null && chmod +x /usr/local/bin/vcluster &

# Wait for background downloads
wait

echo "Background setup completed!"
