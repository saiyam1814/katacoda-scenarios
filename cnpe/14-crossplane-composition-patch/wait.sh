#!/bin/bash
echo "Installing Crossplane + provider-kubernetes (2-4 minutes)."
echo -n "Working"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. Files: /root/composition.yaml (incomplete) and /root/app-xr.yaml (the XR)."
