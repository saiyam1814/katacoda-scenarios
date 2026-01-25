#!/bin/bash

# Verify step 2 - vLLM deployment
echo "🔍 Verifying vLLM deployment..."

# Check if vLLM pod is running
if kubectl get pods -l app=vllm-server -n llm-workshop 2>/dev/null | grep -q "Running"; then
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

# Check if deployment file exists
if [ -f "/root/workspace/llm-workshop/vllm-deployment.yaml" ]; then
    echo "✅ vLLM deployment manifest created"
else
    echo "❌ vLLM deployment manifest not found"
    exit 1
fi

# Check if pod is using CPU (not GPU)
if kubectl describe pod -l app=vllm-server -n llm-workshop 2>/dev/null | grep -q "cpu"; then
    echo "✅ vLLM is configured for CPU mode"
else
    echo "⚠️  Could not verify CPU mode configuration"
fi

echo "✅ Step 2 verification completed successfully!"
