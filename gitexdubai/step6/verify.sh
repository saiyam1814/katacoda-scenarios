#!/bin/bash

# Verify step 6 - Multi-tenancy with vcluster
echo "🔍 Verifying multi-tenancy setup..."

# Check if vclusters exist
if kubectl get vclusters -n llm-workshop | grep -q "team-a"; then
    echo "✅ Team A vcluster created"
else
    echo "❌ Team A vcluster not found"
    exit 1
fi

if kubectl get vclusters -n llm-workshop | grep -q "team-b"; then
    echo "✅ Team B vcluster created"
else
    echo "❌ Team B vcluster not found"
    exit 1
fi

# Check if vcluster pods are running
if kubectl get pods -l app=vcluster -n llm-workshop | grep -q "Running"; then
    echo "✅ vcluster pods are running"
else
    echo "❌ vcluster pods are not running"
    exit 1
fi

echo "✅ Step 6 verification completed successfully!"
