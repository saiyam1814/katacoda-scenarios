#!/bin/bash
echo -n "Deploying the storage-lab workloads"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 2; done
echo ""
echo "Environment ready — two Deployments in storage-lab are waiting for storage."
