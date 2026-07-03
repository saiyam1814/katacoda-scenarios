#!/bin/bash

# Verify Step 5: chaos Workflow created and app healthy

if ! kubectl get workflow chaos-campaign -n demo &>/dev/null; then
    echo "Workflow chaos-campaign not found - apply /root/chaos-workflow.yaml first"
    exit 1
fi
echo "Chaos workflow found"

READY_REPLICAS=$(kubectl get deployment nginx -n demo -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "${READY_REPLICAS:-0}" -ge 3 ]; then
    echo "nginx survived the campaign: $READY_REPLICAS/3 replicas ready"
else
    echo "nginx deployment not fully recovered yet (${READY_REPLICAS:-0}/3) - wait for the workflow to finish"
    exit 1
fi

echo "Step 5 verified successfully!"
