#!/bin/bash

# LLM on Kubernetes Workshop Setup Script
# GITEX Dubai 2025

set -e

echo "🚀 Setting up LLM on Kubernetes Workshop..."

# Create namespace
echo "📦 Creating workshop namespace..."
kubectl create namespace llm-workshop --dry-run=client -o yaml | kubectl apply -f -

# Set context
kubectl config set-context --current --namespace=llm-workshop

# Deploy vLLM
echo "🤖 Deploying vLLM..."
kubectl apply -f /home/vllm-deployment.yaml

# Wait for vLLM to be ready
echo "⏳ Waiting for vLLM to be ready..."
kubectl wait --for=condition=ready pod -l app=vllm-server -n llm-workshop --timeout=300s

# Create port forward
echo "🌐 Setting up port forward..."
kubectl port-forward svc/vllm-service 8000:8000 -n llm-workshop &

echo "✅ Workshop setup completed!"
echo "🌐 vLLM API available at: http://localhost:8000"
