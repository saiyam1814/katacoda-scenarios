#!/bin/bash

# Verify that the nginx-deployment exists and has 3 replicas
kubectl get deployment nginx-deployment -n k8s-primer &> /dev/null
if [ $? -eq 0 ]; then
    READY_REPLICAS=$(kubectl get deployment nginx-deployment -n k8s-primer -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    DESIRED_REPLICAS=$(kubectl get deployment nginx-deployment -n k8s-primer -o jsonpath='{.spec.replicas}' 2>/dev/null)
    if [ "$READY_REPLICAS" == "$DESIRED_REPLICAS" ] && [ "$DESIRED_REPLICAS" == "3" ]; then
        echo "done"
    else
        exit 1
    fi
else
    exit 1
fi
