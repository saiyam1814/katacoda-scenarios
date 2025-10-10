#!/bin/bash

# Verify step 5 - RAG application
echo "🔍 Verifying RAG application..."

# Check if documents directory exists
if [ -d "/root/workspace/llm-workshop/rag-app/documents" ]; then
    echo "✅ Documents directory created"
else
    echo "❌ Documents directory not found"
    exit 1
fi

# Check if kubernetes-basics.txt exists
if [ -f "/root/workspace/llm-workshop/rag-app/documents/kubernetes-basics.txt" ]; then
    echo "✅ Sample document created"
else
    echo "❌ Sample document not found"
    exit 1
fi

# Check if simple-rag.py exists
if [ -f "/root/workspace/llm-workshop/rag-app/simple-rag.py" ]; then
    echo "✅ RAG application script created"
else
    echo "❌ RAG application script not found"
    exit 1
fi

# Check if script is executable
if [ -x "/root/workspace/llm-workshop/rag-app/simple-rag.py" ]; then
    echo "✅ RAG script is executable"
else
    echo "❌ RAG script is not executable"
    exit 1
fi

echo "✅ Step 5 verification completed successfully!"
