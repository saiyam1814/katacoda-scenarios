#!/bin/bash

# Verify Step 2: pod-scenarios chaos experiment ran

# A krkn-hub pod-scenarios container should exist (running or exited)
if podman ps -a --format '{{.Image}}' 2>/dev/null | grep -q "pod-scenarios"; then
    echo "pod-scenarios chaos container found"
else
    echo "No pod-scenarios run found - run 'krknctl run pod-scenarios ...' first"
    exit 1
fi

# The deployment should have healed back to 3 replicas
READY_REPLICAS=$(kubectl get deployment nginx -n demo -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "${READY_REPLICAS:-0}" -ge 3 ]; then
    echo "nginx deployment recovered: $READY_REPLICAS/3 replicas ready"
else
    echo "nginx deployment has not recovered yet (${READY_REPLICAS:-0}/3 ready) - wait for the scenario to finish"
    exit 1
fi

echo "Step 2 verified successfully!"
