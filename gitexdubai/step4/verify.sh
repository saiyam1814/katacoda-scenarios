#!/bin/bash

# Verify step 4 - LLM model testing
echo "🔍 Verifying LLM model functionality..."

# Check if vLLM API is responding
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ vLLM API is responding"
else
    echo "❌ vLLM API is not responding"
    exit 1
fi

# Check if models endpoint works
if curl -s http://localhost:8000/v1/models | jq -e '.data' > /dev/null 2>&1; then
    echo "✅ Models endpoint is working"
else
    echo "❌ Models endpoint is not working"
    exit 1
fi

# Test a simple completion
response=$(curl -s -X POST http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "Hello",
    "max_tokens": 10
  }')

if echo "$response" | jq -e '.choices[0].text' > /dev/null 2>&1; then
    echo "✅ Model completion is working"
else
    echo "❌ Model completion is not working"
    exit 1
fi

echo "✅ Step 4 verification completed successfully!"
