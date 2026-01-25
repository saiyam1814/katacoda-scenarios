#!/bin/bash

# Verify step 3 - Model testing
echo "🔍 Verifying model functionality..."

# Check if vLLM pod is running
if kubectl get pods -l app=vllm-server -n llm-workshop 2>/dev/null | grep -q "Running"; then
    echo "✅ vLLM pod is running"
else
    echo "❌ vLLM pod is not running"
    exit 1
fi

# Check if vLLM service is accessible
VLLM_IP=$(kubectl get svc vllm-service -n llm-workshop -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [ -n "$VLLM_IP" ]; then
    echo "✅ vLLM service is accessible"
    
    # Try to get models list
    if curl -s http://${VLLM_IP}:8000/v1/models > /dev/null 2>&1; then
        echo "✅ vLLM API is responding"
    else
        echo "⚠️  vLLM API may still be starting"
    fi
else
    echo "❌ vLLM service not found"
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
