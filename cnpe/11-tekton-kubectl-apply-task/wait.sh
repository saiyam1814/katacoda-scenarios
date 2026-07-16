#!/bin/bash
echo -n "Installing Tekton Pipelines and the compile-release Pipeline"
while [ ! -f /tmp/.cnpe-setup-done ]; do echo -n "."; sleep 3; done
echo ""
echo "Ready. Pipeline compile-release (tasks: build, package) lives in pipeline-lab."
