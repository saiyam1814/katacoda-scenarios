#!/bin/bash

# Verify that webapp-deployment exists and was created from YAML
kubectl get deployment webapp-deployment -n k8s-primer &> /dev/null
if [ $? -eq 0 ]; then
    # Check if the manifest file exists
    if [ -f /root/workspace/k8s-primer/manifests/webapp-deployment.yaml ]; then
        echo "done"
    else
        exit 1
    fi
else
    exit 1
fi
