#!/bin/bash
echo -n "Installing metrics-server and the storefront app"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 2; done
echo ""
echo "Environment ready. Note: 'kubectl top' may need ~60s before first metrics appear."
