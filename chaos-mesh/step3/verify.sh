#!/bin/bash

# Verify Step 3: NetworkChaos experiment was created and reverted

if [ ! -f /root/network-delay.yaml ]; then
    echo "network-delay.yaml not found - create and apply the NetworkChaos first"
    exit 1
fi
echo "NetworkChaos manifest found"

# The experiment should be deleted (reverted) by the end of the step
if kubectl get networkchaos nginx-delay -n demo &>/dev/null; then
    echo "nginx-delay NetworkChaos still active - delete it to revert the fault"
    exit 1
fi
echo "NetworkChaos reverted (deleted)"

echo "Step 3 verified successfully!"
