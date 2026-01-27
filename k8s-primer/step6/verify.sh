#!/bin/bash

# Verify that resource-demo deployment exists and has resource requests/limits configured
kubectl get deployment resource-demo -n k8s-primer &> /dev/null
if [ $? -eq 0 ]; then
    # Check if the pod has resources configured
    RESOURCES=$(kubectl get pod -l app=resource-demo -n k8s-primer -o jsonpath='{.items[0].spec.containers[0].resources}' 2>/dev/null)
    if [ -n "$RESOURCES" ] && echo "$RESOURCES" | grep -q "requests\|limits"; then
        echo "done"
    else
        exit 1
    fi
else
    exit 1
fi
