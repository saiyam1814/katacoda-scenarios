#!/bin/bash

# Verify Step 6: krkn-visualize deployed and reachable

if ! kubectl get deployment krkn-visualize -n krkn-visualize &>/dev/null; then
    echo "krkn-visualize not found - run 'krknctl visualize ...' first"
    exit 1
fi
echo "krkn-visualize deployment found"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null)
case "$HTTP_CODE" in
    2*|3*)
        echo "Krkn web UI reachable on port 3000 (HTTP $HTTP_CODE)"
        ;;
    *)
        echo "Web UI not reachable on localhost:3000 (got HTTP ${HTTP_CODE:-none}) - run the port-forward command"
        exit 1
        ;;
esac

echo "Step 6 verified successfully!"
