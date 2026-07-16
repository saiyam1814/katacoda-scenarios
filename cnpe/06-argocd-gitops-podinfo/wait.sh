#!/bin/bash
echo "Installing Argo CD - takes about 2 minutes."
echo -n "Working"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Argo CD is running in namespace argocd. You will work declaratively - no UI needed."
