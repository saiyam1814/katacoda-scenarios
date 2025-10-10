#!/bin/bash

# LLM on Kubernetes Workshop Cleanup Script
# GITEX Dubai 2025

set -e

echo "🧹 Cleaning up LLM on Kubernetes Workshop..."

# Delete workshop namespace
echo "🗑️ Deleting workshop namespace..."
kubectl delete namespace llm-workshop --ignore-not-found=true

# Kill any remaining port forwards
echo "🗑️ Stopping port forwards..."
pkill -f "kubectl port-forward" || true

echo "✅ Cleanup completed!"
