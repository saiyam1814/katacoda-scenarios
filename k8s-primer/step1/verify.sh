#!/bin/bash

# Verify that the nginx-pod exists and is running
kubectl get pod nginx-pod -n k8s-primer &> /dev/null
if [ $? -eq 0 ]; then
    POD_STATUS=$(kubectl get pod nginx-pod -n k8s-primer -o jsonpath='{.status.phase}' 2>/dev/null)
    if [ "$POD_STATUS" == "Running" ]; then
        echo "done"
    else
        exit 1
    fi
else
    exit 1
fi
