#!/bin/bash

# Verify step 3 - Model testing
echo "🔍 Verifying model functionality..."

# Check if Ollama pod is running
if kubectl get pods -l app=ollama-server -n llm-workshop 2>/dev/null | grep -q "Running"; then
    echo "✅ Ollama pod is running"
else
    echo "❌ Ollama pod is not running"
    exit 1
fi

# Check if TinyLlama model is available
if kubectl exec deployment/ollama-server -n llm-workshop -- ollama list 2>/dev/null | grep -q "tinyllama"; then
    echo "✅ TinyLlama model is available"
else
    echo "❌ TinyLlama model not found"
    exit 1
fi

# Check if test script exists
if [ -f "/root/workspace/llm-workshop/test-model.sh" ]; then
    echo "✅ Test script created"
    if [ -x "/root/workspace/llm-workshop/test-model.sh" ]; then
        echo "✅ Test script is executable"
    else
        echo "⚠️  Test script is not executable"
    fi
else
    echo "❌ Test script not found"
    exit 1
fi

echo "✅ Step 3 verification completed successfully!"
