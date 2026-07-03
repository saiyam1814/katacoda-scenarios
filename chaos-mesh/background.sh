#!/bin/bash

# Background setup - runs while the user reads the intro
echo "Setting up Chaos Mesh playground environment..."

CHAOS_MESH_VERSION="2.8.3"

# Make sure helm is available
if ! command -v helm &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Add the Chaos Mesh chart repo
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo update chaos-mesh

# Create namespaces
kubectl create namespace chaos-mesh --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace demo --dry-run=client -o yaml | kubectl apply -f -

# NetworkChaos uses tc netem; make sure the kernel module is loaded on both nodes
modprobe sch_netem 2>/dev/null || true
ssh -o StrictHostKeyChecking=no node01 "modprobe sch_netem" 2>/dev/null || true

# Pre-pull the Chaos Mesh images on both nodes so the helm install in step 1
# is fast (kubelet uses containerd, so pull via ctr into the k8s.io namespace)
for img in chaos-mesh chaos-daemon chaos-dashboard; do
    ctr -n k8s.io image pull "ghcr.io/chaos-mesh/${img}:v${CHAOS_MESH_VERSION}" >/dev/null 2>&1 &
    ssh -o StrictHostKeyChecking=no node01 "ctr -n k8s.io image pull ghcr.io/chaos-mesh/${img}:v${CHAOS_MESH_VERSION}" >/dev/null 2>&1 &
done
wait

# Marker used by the steps
touch /tmp/.chaos-mesh-setup-done
echo "Background setup completed!"
