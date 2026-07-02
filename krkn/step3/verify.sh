#!/bin/bash

# Verify Step 3: failure experiment ran against the naked pod

# At least 2 pod-scenarios containers should exist (step 2 + the naked pod run)
RUN_COUNT=$(podman ps -a --format '{{.Image}}' 2>/dev/null | grep -c "pod-scenarios")
if [ "${RUN_COUNT:-0}" -ge 2 ]; then
    echo "Found $RUN_COUNT pod-scenarios runs"
else
    echo "Run the pod-scenarios experiment against the standalone pod first"
    exit 1
fi

# The naked pod should be gone (killed and never recovered)
if kubectl get pod standalone -n demo &>/dev/null; then
    echo "The standalone pod still exists - wait for the chaos scenario to finish"
    exit 1
else
    echo "The standalone pod is gone and never recovered - weakness found!"
fi

echo "Step 3 verified successfully!"
