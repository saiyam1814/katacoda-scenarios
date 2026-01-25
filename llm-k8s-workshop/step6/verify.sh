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

# Check if simple RAG script exists
if [ -f "/root/workspace/llm-workshop/rag-app/simple-rag.sh" ]; then
    echo "✅ Simple RAG script created"
else
    echo "❌ Simple RAG script not found"
    exit 1
fi

# Check if vector RAG script exists
if [ -f "/root/workspace/llm-workshop/rag-app/vector-rag.py" ]; then
    echo "✅ Vector RAG script created"
else
    echo "❌ Vector RAG script not found"
    exit 1
fi

# Check if embedding model is available
if kubectl exec deployment/ollama-server -n llm-workshop -- ollama list 2>/dev/null | grep -q "all-minilm"; then
    echo "✅ Embedding model (all-minilm) available"
else
    echo "⚠️  Embedding model not yet pulled (run: ollama pull all-minilm)"
fi

# Check if embeddings file exists (optional - created during indexing)
if [ -f "/root/workspace/llm-workshop/rag-app/embeddings.json" ]; then
    echo "✅ Document embeddings indexed"
else
    echo "⚠️  Documents not yet indexed (run: python3 vector-rag.py index)"
fi

echo "✅ Step 6 verification completed successfully!"
