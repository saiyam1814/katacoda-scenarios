#!/bin/bash

# Verify Step 3: RAG pipeline built

# Check documents directory
if [ -d "/root/workshop/rag-app/documents" ]; then
    DOC_COUNT=$(ls /root/workshop/rag-app/documents/*.txt 2>/dev/null | wc -l)
    if [ "$DOC_COUNT" -ge 3 ]; then
        echo "Knowledge base: $DOC_COUNT documents"
    else
        echo "Not enough documents (found $DOC_COUNT, need at least 3)"
        exit 1
    fi
else
    echo "Documents directory not found"
    exit 1
fi

# Check simple RAG script
if [ -f "/root/workshop/rag-app/simple-rag.sh" ] && [ -x "/root/workshop/rag-app/simple-rag.sh" ]; then
    echo "Simple RAG script created"
else
    echo "Simple RAG script not found or not executable"
    exit 1
fi

echo "Step 3 verified successfully!"
