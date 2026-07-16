#!/bin/bash
echo -n "Deploying tenant-red, ingress-gw and other-squad"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 2; done
echo ""
echo "Environment ready. Three namespaces are in play - check their labels."
