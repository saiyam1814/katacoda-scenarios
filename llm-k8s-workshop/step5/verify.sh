#!/bin/bash

# Verify step 5 - LLM interaction
echo "🔍 Verifying LLM interaction..."

# Check if vLLM pod is running
if kubectl get pods -l app=vllm-server -n llm-workshop 2>/dev/null | grep -q "Running"; then
    echo "✅ vLLM pod is running"
else
    echo "❌ vLLM pod is not running"
    exit 1
fi

# Check if helper script exists
if [ -f "/root/workspace/llm-workshop/ask-vllm.sh" ]; then
    echo "✅ Helper script exists"
else
    echo "❌ Helper script not found"
    exit 1
fi

# Check if port forward is running
if pgrep -f "kubectl port-forward.*vllm-service" > /dev/null; then
    echo "✅ Port forward is active"
    
    # Test API access
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ API is accessible"
    else
        echo "⚠️  API may not be ready"
    fi
else
    echo "⚠️  Port forward not detected"
fi

# Check if question bank exists
if [ -f "/root/workspace/llm-workshop/questions.txt" ]; then
    echo "✅ Question bank created"
else
    echo "⚠️  Question bank not found (optional)"
fi

echo "✅ Step 5 verification completed successfully!"
