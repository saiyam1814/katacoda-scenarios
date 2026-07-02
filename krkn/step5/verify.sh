#!/bin/bash

# Verify Step 5: chaos graph plan created and executed

if [ -f /root/chaos-plan.json ]; then
    echo "Chaos plan found at /root/chaos-plan.json"
else
    echo "Chaos plan not found - create /root/chaos-plan.json first"
    exit 1
fi

# At least 3 pod-scenarios containers total (steps 2, 3 and the graph run)
POD_RUNS=$(podman ps -a --format '{{.Image}}' 2>/dev/null | grep -c "pod-scenarios")
if [ "${POD_RUNS:-0}" -ge 3 ]; then
    echo "Graph pod-scenarios stage executed"
else
    echo "Graph run not detected yet - run 'krknctl graph run /root/chaos-plan.json'"
    exit 1
fi

# The deployment should still be healthy at the end
READY_REPLICAS=$(kubectl get deployment nginx -n demo -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "${READY_REPLICAS:-0}" -ge 3 ]; then
    echo "nginx survived the chaos campaign: $READY_REPLICAS/3 replicas ready"
else
    echo "nginx deployment not fully recovered yet (${READY_REPLICAS:-0}/3) - wait for the graph run to finish"
    exit 1
fi

echo "Step 5 verified successfully!"
