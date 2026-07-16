#!/bin/bash
echo "Installing Tekton Pipelines + Triggers (two controller sets, ~3 minutes)."
echo -n "Working"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. Pipeline build-ship works in ci-otter; SA tekton-triggers is prepared."
