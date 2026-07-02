#!/bin/bash

# Verify Step 4: node-cpu-hog scenario ran

if podman ps -a --format '{{.Image}}' 2>/dev/null | grep -q "node-cpu-hog"; then
    echo "node-cpu-hog chaos container found"
else
    echo "No node-cpu-hog run found - run 'krknctl run node-cpu-hog ...' first"
    exit 1
fi

echo "Step 4 verified successfully!"
