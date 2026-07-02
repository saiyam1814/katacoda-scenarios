#!/bin/bash

# Background setup - runs while the user reads the intro
echo "Setting up Krkn chaos engineering environment..."

# krknctl runs krkn-hub scenario containers locally via podman (or docker).
# Podman ships with this environment; make sure its API socket is up.
systemctl enable --now podman.socket 2>/dev/null || true
systemctl start podman 2>/dev/null || true

# Install krknctl.
# Pinned to v0.10.21-beta: v0.11.0-beta writes the flattened kubeconfig copy
# with 0600 permissions, which the non-root 'krkn' user (uid 1001) inside the
# scenario containers cannot read when krknctl runs as root
# (see https://github.com/krkn-chaos/krknctl/issues/95).
curl -fsSL https://raw.githubusercontent.com/krkn-chaos/krknctl/refs/heads/main/install.sh | bash -s -- --version v0.10.21-beta

# Create the namespace for the target app
kubectl create namespace demo --dry-run=client -o yaml | kubectl apply -f -

# Pre-pull the krkn-hub scenario images with podman - the same runtime
# krknctl uses - so the pulls are actually reused (large images, saves minutes)
podman pull -q quay.io/krkn-chaos/krkn-hub:pod-scenarios &
POD_PULL=$!
podman pull -q quay.io/krkn-chaos/krkn-hub:node-cpu-hog &
CPU_PULL=$!

wait $POD_PULL $CPU_PULL

# Marker used by foreground.sh and step verifications
touch /tmp/.krkn-setup-done
echo "Background setup completed!"
