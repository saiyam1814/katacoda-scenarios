#!/bin/bash

# Verify step 4 - Service exposure
echo "🔍 Verifying service exposure..."

# Check if vLLM service exists
if kubectl get svc vllm-service -n llm-workshop > /dev/null 2>&1; then
    echo "✅ vLLM service exists"
else
    echo "❌ vLLM service not found"
    exit 1
fi

# Check if port forward is running (optional)
if pgrep -f "kubectl port-forward.*vllm-service" > /dev/null; then
    echo "✅ Port forward is active"
    
    # Test localhost access
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ Service is accessible via port forward"
    else
        echo "⚠️  Service may still be starting"
    fi
else
    echo "⚠️  Port forward not detected (may need to be started)"
fi

# Check if helper script exists
if [ -f "/root/workspace/llm-workshop/ask-vllm.sh" ]; then
    echo "✅ Helper script created"
    if [ -x "/root/workspace/llm-workshop/ask-vllm.sh" ]; then
        echo "✅ Helper script is executable"
    else
        echo "⚠️  Helper script is not executable"
    fi
else
    echo "❌ Helper script not found"
    exit 1
fi

echo "✅ Step 4 verification completed successfully!"
