#!/bin/bash

# Verify that the nginx-service exists and has endpoints
kubectl get service nginx-service -n k8s-primer &> /dev/null
if [ $? -eq 0 ]; then
    ENDPOINTS=$(kubectl get endpoints nginx-service -n k8s-primer -o jsonpath='{.subsets[0].addresses[*].ip}' 2>/dev/null)
    if [ -n "$ENDPOINTS" ]; then
        echo "done"
    else
        exit 1
    fi
else
    exit 1
fi
