#!/bin/bash
echo -n "Deploying the fleet (four namespaces, four workloads)"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 2; done
echo ""
echo "Ready. Somewhere in fleet-1..fleet-4, security sins are hiding."
