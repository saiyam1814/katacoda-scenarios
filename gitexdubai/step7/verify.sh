#!/bin/bash

# Verify step 7 - Scaling and optimization
echo "🔍 Verifying scaling setup..."

# Check if HPA exists
if kubectl get hpa vllm-hpa -n llm-workshop > /dev/null 2>&1; then
    echo "✅ HPA created for vLLM"
else
    echo "❌ HPA not found"
    exit 1
fi

# Check if load test script exists
if [ -f "/root/workspace/llm-workshop/load-test.sh" ]; then
    echo "✅ Load test script created"
else
    echo "❌ Load test script not found"
    exit 1
fi

# Check if monitor script exists
if [ -f "/root/workspace/llm-workshop/monitor.sh" ]; then
    echo "✅ Monitor script created"
else
    echo "❌ Monitor script not found"
    exit 1
fi

# Check if scripts are executable
if [ -x "/root/workspace/llm-workshop/load-test.sh" ] && [ -x "/root/workspace/llm-workshop/monitor.sh" ]; then
    echo "✅ Scripts are executable"
else
    echo "❌ Scripts are not executable"
    exit 1
fi

echo "✅ Step 7 verification completed successfully!"
