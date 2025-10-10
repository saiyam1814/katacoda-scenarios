#!/bin/bash

# Verify step 2 - Environment setup
echo "🔍 Verifying environment setup..."

# Check if namespace exists
if kubectl get namespace llm-workshop > /dev/null 2>&1; then
    echo "✅ Namespace 'llm-workshop' created"
else
    echo "❌ Namespace 'llm-workshop' not found"
    exit 1
fi

# Check if tools are installed
if command -v helm &> /dev/null; then
    echo "✅ Helm installed"
else
    echo "❌ Helm not installed"
    exit 1
fi

if command -v vcluster &> /dev/null; then
    echo "✅ vcluster CLI installed"
else
    echo "❌ vcluster CLI not installed"
    exit 1
fi

if command -v jq &> /dev/null; then
    echo "✅ jq installed"
else
    echo "❌ jq not installed"
    exit 1
fi

# Check if resource quota exists
if kubectl get resourcequota llm-workshop-quota -n llm-workshop > /dev/null 2>&1; then
    echo "✅ Resource quota configured"
else
    echo "❌ Resource quota not found"
    exit 1
fi

echo "✅ Step 2 verification completed successfully!"
