#!/bin/bash
echo "Installing Istio (minimal) and three sidecar-injected namespaces (~3 minutes)."
echo -n "Working"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. payments/checkout serves; web/storefront and batch/reporting want to call it."
