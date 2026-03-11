#!/bin/bash

# Verify Step 1: Ollama deployed on Kubernetes

# Check namespace exists
if ! kubectl get namespace ai-workshop &>/dev/null; then
    echo "Namespace 'ai-workshop' not found"
    exit 1
fi

# Check Ollama pod is running
if kubectl get pods -l app=ollama -n ai-workshop 2>/dev/null | grep -q "Running"; then
    echo "Ollama pod is running"
else
    echo "Ollama pod is not running yet"
    exit 1
fi

# Check Ollama service exists
if kubectl get svc ollama -n ai-workshop &>/dev/null; then
    echo "Ollama service created"
else
    echo "Ollama service not found"
    exit 1
fi

# Check manifest file exists
if [ -f "/root/workshop/manifests/ollama-deployment.yaml" ]; then
    echo "Deployment manifest created"
else
    echo "Deployment manifest not found"
    exit 1
fi

echo "Step 1 verified successfully!"
