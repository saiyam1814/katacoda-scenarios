#!/bin/bash

# Background setup for LLM on Kubernetes workshop
# This script runs in the background during the workshop

echo "🚀 Setting up LLM on Kubernetes workshop environment..."

# Create workshop directory
mkdir -p /root/workspace/llm-workshop

# Install required tools
echo "📦 Installing required tools..."

# Install Helm
if ! command -v helm &> /dev/null; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Install vcluster CLI
if ! command -v vcluster &> /dev/null; then
    echo "Installing vcluster CLI..."
    curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64"
    chmod +x vcluster
    sudo mv vcluster /usr/local/bin
fi

# Install jq
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    apt-get update && apt-get install -y jq
fi

# Create namespace
echo "📦 Creating workshop namespace..."
kubectl create namespace llm-workshop --dry-run=client -o yaml | kubectl apply -f -

# Set context
kubectl config set-context --current --namespace=llm-workshop

# Create resource quota
echo "📊 Setting up resource quotas..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: llm-workshop-quota
  namespace: llm-workshop
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "10"
EOF

echo "✅ Background setup completed!"
