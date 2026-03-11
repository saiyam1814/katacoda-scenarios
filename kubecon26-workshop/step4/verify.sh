#!/bin/bash

# Verify Step 4: Vector RAG with semantic search

# Check vector RAG script exists
if [ -f "/root/workshop/rag-app/vector-rag.py" ] && [ -x "/root/workshop/rag-app/vector-rag.py" ]; then
    echo "Vector RAG script created"
else
    echo "Vector RAG script not found"
    exit 1
fi

# Check embedding model is available
if kubectl exec deployment/ollama -n ai-workshop -- ollama list 2>/dev/null | grep -q "all-minilm"; then
    echo "Embedding model (all-minilm) available"
else
    echo "Embedding model not pulled yet"
    exit 1
fi

# Check embeddings file was created
if [ -f "/root/workshop/rag-app/embeddings.json" ]; then
    echo "Document embeddings indexed"
else
    echo "Documents not indexed yet - run: python3 vector-rag.py index"
    exit 1
fi

echo "Step 4 verified successfully!"
