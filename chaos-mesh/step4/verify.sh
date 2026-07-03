#!/bin/bash

# Verify Step 4: dashboard reachable

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:2333 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
    echo "Chaos Mesh dashboard is reachable on port 2333"
else
    echo "Dashboard not reachable on localhost:2333 (got HTTP ${HTTP_CODE:-none}) - run the port-forward command"
    exit 1
fi

echo "Step 4 verified successfully!"
