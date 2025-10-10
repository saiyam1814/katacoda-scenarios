#!/bin/bash

# Verify step 3 - vLLM deployment
echo "🔍 Verifying vLLM deployment..."

# Check if vLLM pod is running
if kubectl get pods -l app=vllm-server -n llm-workshop | grep -q "Running"; then
    echo "✅ vLLM pod is running"
else
    echo "❌ vLLM pod is not running"
    exit 1
fi

# Check if vLLM service exists
if kubectl get svc vllm-service -n llm-workshop > /dev/null 2>&1; then
    echo "✅ vLLM service created"
else
    echo "❌ vLLM service not found"
    exit 1
fi

# Check if port forward is working
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ vLLM API is accessible"
else
    echo "❌ vLLM API is not accessible (check port forward)"
    exit 1
fi

echo "✅ Step 3 verification completed successfully!"
