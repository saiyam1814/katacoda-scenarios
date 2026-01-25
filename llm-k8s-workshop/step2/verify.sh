#!/bin/bash

# Verify step 2 - Ollama deployment
echo "🔍 Verifying Ollama deployment..."

# Check if Ollama pod is running
if kubectl get pods -l app=ollama-server -n llm-workshop 2>/dev/null | grep -q "Running"; then
    echo "✅ Ollama pod is running"
else
    echo "❌ Ollama pod is not running"
    exit 1
fi

# Check if Ollama service exists
if kubectl get svc ollama-service -n llm-workshop > /dev/null 2>&1; then
    echo "✅ Ollama service created"
else
    echo "❌ Ollama service not found"
    exit 1
fi

# Check if deployment file exists
if [ -f "/root/workspace/llm-workshop/ollama-deployment.yaml" ]; then
    echo "✅ Ollama deployment manifest created"
else
    echo "❌ Ollama deployment manifest not found"
    exit 1
fi

echo "✅ Step 2 verification completed successfully!"
