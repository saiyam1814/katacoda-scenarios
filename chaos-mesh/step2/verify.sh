#!/bin/bash

# Verify Step 2: PodChaos experiment ran and app healed

if [ ! -f /root/pod-kill.yaml ]; then
    echo "pod-kill.yaml not found - create and apply the PodChaos first"
    exit 1
fi
echo "PodChaos manifest found"

READY_REPLICAS=$(kubectl get deployment nginx -n demo -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "${READY_REPLICAS:-0}" -ge 3 ]; then
    echo "nginx deployment recovered: $READY_REPLICAS/3 replicas ready"
else
    echo "nginx deployment not recovered yet (${READY_REPLICAS:-0}/3)"
    exit 1
fi

echo "Step 2 verified successfully!"
