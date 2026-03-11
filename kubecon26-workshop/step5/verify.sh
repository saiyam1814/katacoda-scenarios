#!/bin/bash

# Verify Step 5: vCluster multi-tenant AI

# Check if vCluster CLI is available
if command -v vcluster &>/dev/null; then
    echo "vCluster CLI installed"
else
    echo "vCluster CLI not found"
    exit 1
fi

# Check if team-ml namespace exists (indicates vCluster was created)
if kubectl get namespace team-ml &>/dev/null; then
    echo "team-ml namespace exists"
else
    echo "team-ml namespace not found - create vCluster first"
    exit 1
fi

# Check if vCluster pods are running in team-ml namespace
if kubectl get pods -n team-ml 2>/dev/null | grep -q "Running\|Completed"; then
    echo "vCluster components running in team-ml"
else
    echo "vCluster pods not ready in team-ml"
    exit 1
fi

echo "Step 5 verified successfully!"
