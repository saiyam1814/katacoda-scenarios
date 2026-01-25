#!/bin/bash

# Verify step 5 - LLM interaction
echo "🔍 Verifying LLM interaction..."

# Check if Ollama pod is running
if kubectl get pods -l app=ollama-server -n llm-workshop 2>/dev/null | grep -q "Running"; then
    echo "✅ Ollama pod is running"
else
    echo "❌ Ollama pod is not running"
    exit 1
fi

# Check if helper script exists
if [ -f "/root/workspace/llm-workshop/ask-ollama.sh" ]; then
    echo "✅ Helper script exists"
else
    echo "❌ Helper script not found"
    exit 1
fi

# Check if question bank exists
if [ -f "/root/workspace/llm-workshop/questions.txt" ]; then
    echo "✅ Question bank created"
else
    echo "⚠️  Question bank not found (optional)"
fi

echo "✅ Step 5 verification completed successfully!"
