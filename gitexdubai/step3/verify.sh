#!/bin/bash

# Verify step 3 - Ollama deployment
echo "🔍 Verifying Ollama deployment..."

# Check if Ollama pod is running
if kubectl get pods -l app=ollama-server -n llm-workshop | grep -q "Running"; then
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

# Check if TinyLlama model is available (non-interactive check)
if kubectl exec deployment/ollama-server -n llm-workshop -- ollama list 2>/dev/null | grep -q "tinyllama"; then
    echo "✅ TinyLlama model is available"
else
    echo "❌ TinyLlama model not found"
    exit 1
fi

# Check if port forward is working (optional)
if pgrep -f "kubectl port-forward.*ollama-service" > /dev/null; then
    echo "✅ Port forward is active"
else
    echo "⚠️  Port forward not detected (optional)"
fi

echo "✅ Step 3 verification completed successfully!"
