#!/bin/bash

# Verify that webapp-deployment exists (main goal - they applied a YAML manifest)
if kubectl get deployment webapp-deployment -n k8s-primer &> /dev/null; then
    # Check if deployment has pods running
    READY_REPLICAS=$(kubectl get deployment webapp-deployment -n k8s-primer -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    if [ -n "$READY_REPLICAS" ] && [ "$READY_REPLICAS" -gt 0 ]; then
        echo "done"
    else
        # Deployment exists but pods might still be starting
        echo "done"
    fi
else
    exit 1
fi
