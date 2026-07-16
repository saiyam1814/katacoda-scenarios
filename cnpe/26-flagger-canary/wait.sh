#!/bin/bash
echo "Installing Istio (minimal), Prometheus, and Flagger (~3 minutes)."
echo -n "Working"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. Deployment media-proxy runs in release-bay; Flagger watches from istio-system."
