#!/bin/bash
echo -n "Installing Tekton and the gate-less build-ship pipeline"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. Pipeline build-ship (ci-otter) currently ships ANY image. Scary."
