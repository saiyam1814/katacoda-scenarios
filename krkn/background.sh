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

# krknctl fetches scenario metadata from quay.io on every invocation and
# panics (Go exit status 2) if that request transiently fails: it does
# resp, _ := http.Get(...) and then dereferences a nil resp. The fetch
# happens before any chaos container starts, so retrying is always safe.
# Wrap it in the interactive shell until it is fixed upstream.
cat >> /root/.bashrc <<'EOF'

krknctl() {
    local rc attempt
    for attempt in 1 2 3; do
        command krknctl "$@"
        rc=$?
        [ "$rc" -ne 2 ] && return "$rc"
        echo ""
        echo ">>> krknctl hit a transient quay.io metadata error (known upstream bug), retrying $attempt/3..."
        sleep 3
    done
    return "$rc"
}
EOF

# Create the namespace for the target app
kubectl create namespace demo --dry-run=client -o yaml | kubectl apply -f -

# Label the worker so kube-state-metrics exposes kube_node_role for it -
# the krkn-visualize k8s dashboards filter nodes by role=worker
kubectl label node node01 node-role.kubernetes.io/worker= --overwrite 2>/dev/null || true

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

# --- Step 6 (web UI) prerequisites - not needed until late in the tutorial,
# --- so they run after the main marker and never block steps 1-5.

# Minimal Prometheus (server + node-exporter + kube-state-metrics) that the
# krkn-visualize k8s dashboards read from. No PV (no dynamic provisioner here).
if ! command -v helm &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring --create-namespace \
  --set alertmanager.enabled=false \
  --set prometheus-pushgateway.enabled=false \
  --set server.persistentVolume.enabled=false

# Pre-pull the krkn-visualize images: the deployer container (runs via podman)
# and the in-cluster images (grafana, renderer, dashboard syncer) on both nodes
podman pull -q quay.io/krkn-chaos/krkn-visualize:latest &
for img in "docker.io/grafana/grafana:10.4.0" "docker.io/grafana/grafana-image-renderer:latest" "quay.io/krkn-chaos/visualize-syncer:opensearch-latest"; do
    ctr -n k8s.io image pull "$img" >/dev/null 2>&1 &
    ssh -o StrictHostKeyChecking=no node01 "ctr -n k8s.io image pull $img" >/dev/null 2>&1 &
done
wait

touch /tmp/.krkn-visualize-ready
echo "Web UI prerequisites ready!"
