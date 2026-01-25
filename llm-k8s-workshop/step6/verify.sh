#!/bin/bash

# Verify step 6 - RAG application
echo "🔍 Verifying RAG application..."

# Check if documents directory exists
if [ -d "/root/workspace/llm-workshop/rag-app/documents" ]; then
    echo "✅ Documents directory created"
else
    echo "❌ Documents directory not found"
    exit 1
fi

# Check if sample documents exist
if [ -f "/root/workspace/llm-workshop/rag-app/documents/kubernetes-basics.txt" ]; then
    echo "✅ Sample documents created"
else
    echo "❌ Sample documents not found"
    exit 1
fi

# Check if RAG script exists
if [ -f "/root/workspace/llm-workshop/rag-app/simple-rag.sh" ]; then
    echo "✅ RAG application script created"
    if [ -x "/root/workspace/llm-workshop/rag-app/simple-rag.sh" ]; then
        echo "✅ RAG script is executable"
    else
        echo "⚠️  RAG script is not executable"
    fi
else
    echo "❌ RAG application script not found"
    exit 1
fi

echo "✅ Step 6 verification completed successfully!"
