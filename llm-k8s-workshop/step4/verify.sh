#!/bin/bash

# Verify step 4 - Service exposure
echo "🔍 Verifying service exposure..."

# Check if Ollama service exists
if kubectl get svc ollama-service -n llm-workshop > /dev/null 2>&1; then
    echo "✅ Ollama service exists"
else
    echo "❌ Ollama service not found"
    exit 1
fi

# Check if port forward is running (optional)
if pgrep -f "kubectl port-forward.*ollama-service" > /dev/null; then
    echo "✅ Port forward is active"
else
    echo "⚠️  Port forward not detected (may need to be started)"
fi

# Check if helper script exists
if [ -f "/root/workspace/llm-workshop/ask-ollama.sh" ]; then
    echo "✅ Helper script created"
    if [ -x "/root/workspace/llm-workshop/ask-ollama.sh" ]; then
        echo "✅ Helper script is executable"
    else
        echo "⚠️  Helper script is not executable"
    fi
else
    echo "❌ Helper script not found"
    exit 1
fi

echo "✅ Step 4 verification completed successfully!"
