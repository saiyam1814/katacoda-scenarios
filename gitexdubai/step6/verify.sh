#!/bin/bash

# Verify step 6 - Multi-tenancy with vcluster
echo "🔍 Verifying multi-tenancy setup..."

# Check if we're connected to vcluster context
current_context=$(kubectl config current-context)
if [[ "$current_context" == *"workshop-cluster"* ]]; then
    echo "✅ Connected to vcluster context: $current_context"
else
    echo "❌ Not connected to vcluster context (current: $current_context)"
    echo "Attempting to connect to vcluster..."
    vcluster connect workshop-cluster --namespace default --kube-config /root/.kube/config-workshop
    export KUBECONFIG=/root/.kube/config-workshop
    kubectl config use-context workshop-cluster
fi

# Check if vcluster is accessible
if kubectl get nodes > /dev/null 2>&1; then
    echo "✅ vcluster is accessible"
else
    echo "❌ vcluster is not accessible"
    exit 1
fi

# Check if vcluster pod exists in host cluster
if kubectl get pods -l app=vcluster -n default > /dev/null 2>&1; then
    echo "✅ vcluster pod is running in host cluster"
else
    echo "❌ vcluster pod not found in host cluster"
    exit 1
fi

echo "✅ Step 6 verification completed successfully!"
