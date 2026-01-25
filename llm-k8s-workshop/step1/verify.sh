#!/bin/bash

# Verify step 1 - Kubernetes cluster setup
echo "🔍 Verifying Kubernetes cluster setup..."

# Check if namespace exists
if kubectl get namespace llm-workshop > /dev/null 2>&1; then
    echo "✅ Namespace 'llm-workshop' created"
else
    echo "❌ Namespace 'llm-workshop' not found"
    exit 1
fi

# Check if we're in the correct namespace
CURRENT_NS=$(kubectl config view --minify -o jsonpath='{..namespace}')
if [ "$CURRENT_NS" == "llm-workshop" ]; then
    echo "✅ Context set to llm-workshop namespace"
else
    echo "⚠️  Context namespace is '$CURRENT_NS' (expected: llm-workshop)"
fi

# Check if workspace directory exists
if [ -d "/root/workspace/llm-workshop" ]; then
    echo "✅ Workspace directory created"
else
    echo "❌ Workspace directory not found"
    exit 1
fi

echo "✅ Step 1 verification completed successfully!"
