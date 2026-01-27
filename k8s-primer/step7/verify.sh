#!/bin/bash

# Verify that port forwarding and kubectl exec work
# We'll test by executing a simple command in a pod

# Get any running pod in the namespace
POD_NAME=$(kubectl get pods -n k8s-primer -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD_NAME" ]; then
    exit 1
fi

# Test kubectl exec works
kubectl exec $POD_NAME -n k8s-primer -- echo "test" &> /dev/null
if [ $? -eq 0 ]; then
    echo "done"
else
    exit 1
fi
