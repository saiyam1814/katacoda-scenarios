#!/bin/bash

# Verify that the nginx-nodeport service exists and has a NodePort
kubectl get service nginx-nodeport -n k8s-primer &> /dev/null
if [ $? -eq 0 ]; then
    SERVICE_TYPE=$(kubectl get service nginx-nodeport -n k8s-primer -o jsonpath='{.spec.type}' 2>/dev/null)
    NODEPORT=$(kubectl get service nginx-nodeport -n k8s-primer -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    if [ "$SERVICE_TYPE" == "NodePort" ] && [ -n "$NODEPORT" ]; then
        echo "done"
    else
        exit 1
    fi
else
    exit 1
fi
