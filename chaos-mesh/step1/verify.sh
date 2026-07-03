#!/bin/bash

# Verify Step 1: Chaos Mesh installed, target app deployed

if ! kubectl get pods -n chaos-mesh 2>/dev/null | grep -q "chaos-controller-manager"; then
    echo "Chaos Mesh controller not found - run the helm install first"
    exit 1
fi
echo "Chaos Mesh components found"

READY_REPLICAS=$(kubectl get deployment nginx -n demo -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "${READY_REPLICAS:-0}" -ge 3 ]; then
    echo "nginx deployment ready with $READY_REPLICAS replicas"
else
    echo "nginx deployment not ready in namespace demo (${READY_REPLICAS:-0}/3)"
    exit 1
fi

if kubectl get pod client -n demo &>/dev/null; then
    echo "client pod exists"
else
    echo "client pod not found - create it with kubectl run"
    exit 1
fi

echo "Step 1 verified successfully!"
