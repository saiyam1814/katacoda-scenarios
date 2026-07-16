#!/bin/bash
echo -n "Installing Argo Workflows and preparing RBAC"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 2; done
echo ""
echo "Ready. ServiceAccount workflow-runner (ns workflows) may deploy into demo-reef."
