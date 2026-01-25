#!/bin/bash

# Background setup for LLM on Kubernetes workshop
# This script runs in the background during the workshop

echo "🚀 Setting up LLM on Kubernetes workshop environment..."

# Create workshop directory
mkdir -p /root/workspace/llm-workshop

# Create namespace
echo "📦 Creating workshop namespace..."
kubectl create namespace llm-workshop --dry-run=client -o yaml | kubectl apply -f -

# Set context
kubectl config set-context --current --namespace=llm-workshop

echo "✅ Background setup completed!"
