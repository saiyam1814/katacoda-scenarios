#!/bin/bash
echo "Installing Istio (minimal), Argo Rollouts, and the media-proxy stack."
echo "Takes 2-3 minutes."
echo -n "Working"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. Namespace release-bay has: Deployment media-proxy, Services media-proxy /"
echo "media-proxy-stable / media-proxy-canary, and VirtualService media-proxy (route: primary)."
