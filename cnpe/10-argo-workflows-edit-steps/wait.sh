#!/bin/bash
echo -n "Installing Argo Workflows and staging the release-checker pipeline"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 2; done
echo ""
echo "Ready. The pipeline definition is at /root/release-checker.yaml"
