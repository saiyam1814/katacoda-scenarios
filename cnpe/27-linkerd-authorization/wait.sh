#!/bin/bash
echo "Installing Linkerd and three meshed namespaces (~3 minutes)."
echo -n "Working"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. payments/checkout serves; web/storefront and batch/reporting call it - all meshed."
