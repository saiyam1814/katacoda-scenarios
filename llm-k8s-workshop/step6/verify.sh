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

# Check if RAG app pod is running
if kubectl get pods -l app=rag-app -n llm-workshop 2>/dev/null | grep -q "Running"; then
    echo "✅ RAG application pod is running"
else
    echo "⚠️  RAG application pod may still be starting"
fi

# Check if RAG app service exists
if kubectl get svc rag-app-service -n llm-workshop > /dev/null 2>&1; then
    echo "✅ RAG application service created"
else
    echo "❌ RAG application service not found"
    exit 1
fi

# Check if deployment file exists
if [ -f "/root/workspace/llm-workshop/rag-app-deployment.yaml" ]; then
    echo "✅ RAG deployment manifest created"
else
    echo "❌ RAG deployment manifest not found"
    exit 1
fi

# Check if port forward is running (optional)
if pgrep -f "kubectl port-forward.*rag-app" > /dev/null; then
    echo "✅ RAG app port forward is active"
    
    # Test API access
    if curl -s http://localhost:5001/ > /dev/null 2>&1; then
        echo "✅ RAG application is accessible"
    else
        echo "⚠️  RAG application may still be starting"
    fi
else
    echo "⚠️  RAG app port forward not detected (may need to be started)"
fi

echo "✅ Step 6 verification completed successfully!"
