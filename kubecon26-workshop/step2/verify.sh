#!/bin/bash

# Verify Step 2: TinyLlama model pulled and working

# Check if TinyLlama model is available
if kubectl exec deployment/ollama -n ai-workshop -- ollama list 2>/dev/null | grep -q "tinyllama"; then
    echo "TinyLlama model is available"
else
    echo "TinyLlama model not found - run: ollama pull tinyllama"
    exit 1
fi

# Check if helper script exists
if [ -f "/root/workshop/ask.sh" ]; then
    echo "Helper script created"
else
    echo "Helper script not found"
    exit 1
fi

echo "Step 2 verified successfully!"
