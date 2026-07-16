#!/bin/bash
echo -n "Preparing flags-lab"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 1; done
echo ""
echo "Ready. The target custom resource is at /root/checkout-express.yaml"
