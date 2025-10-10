#!/bin/bash

# Verify step 6 - Multi-tenancy with vcluster
echo "🔍 Verifying multi-tenancy setup..."

# Check if we're in default namespace
current_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
if [ "$current_namespace" = "default" ]; then
    echo "✅ Currently in default namespace"
else
    echo "❌ Not in default namespace (current: $current_namespace)"
    exit 1
fi

# Check if vcluster exists
if kubectl get pods -l app=vcluster -n default | grep -q "Running"; then
    echo "✅ vcluster pod is running"
else
    echo "❌ vcluster pod is not running"
    exit 1
fi

# Check if workshop namespace was deleted
if ! kubectl get namespace llm-workshop > /dev/null 2>&1; then
    echo "✅ Original workshop namespace cleaned up"
else
    echo "⚠️  Original workshop namespace still exists (may be in cleanup)"
fi

echo "✅ Step 6 verification completed successfully!"
