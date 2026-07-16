#!/bin/bash
echo -n "Installing Argo Rollouts and the catalog stack"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 2; done
echo ""
echo "Ready. shop-core has Deployment catalog plus Services catalog-active / catalog-preview."
