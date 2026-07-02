#!/bin/bash

# Background setup - runs while the user reads the intro
echo "Setting up Krkn chaos engineering environment..."

# Make sure docker is available (krknctl needs docker or podman)
if ! command -v docker &>/dev/null; then
    apt-get update -qq && apt-get install -y -qq docker.io
fi
systemctl start docker 2>/dev/null || true

# Install krknctl
curl -fsSL https://raw.githubusercontent.com/krkn-chaos/krknctl/refs/heads/main/install.sh | bash

# Create the namespace for the target app
kubectl create namespace demo --dry-run=client -o yaml | kubectl apply -f -

# Pre-pull the krkn-hub scenario images (large - saves minutes during the steps)
docker pull -q quay.io/krkn-chaos/krkn-hub:pod-scenarios &
POD_PULL=$!
docker pull -q quay.io/krkn-chaos/krkn-hub:node-cpu-hog &
CPU_PULL=$!

wait $POD_PULL $CPU_PULL

# Marker used by foreground.sh and step verifications
touch /tmp/.krkn-setup-done
echo "Background setup completed!"
