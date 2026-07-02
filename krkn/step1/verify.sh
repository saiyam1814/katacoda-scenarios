#!/bin/bash

# Verify Step 1: cluster ready, target app deployed

READY_REPLICAS=$(kubectl get deployment nginx -n demo -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "${READY_REPLICAS:-0}" -ge 3 ]; then
    echo "nginx deployment is running with $READY_REPLICAS ready replicas"
else
    echo "nginx deployment not ready in namespace demo (found ${READY_REPLICAS:-0}/3 ready replicas)"
    exit 1
fi

if kubectl get svc nginx -n demo &>/dev/null; then
    echo "nginx service exists"
else
    echo "nginx service not found - run 'kubectl expose deployment nginx --port=80 -n demo'"
    exit 1
fi

echo "Step 1 verified successfully!"
