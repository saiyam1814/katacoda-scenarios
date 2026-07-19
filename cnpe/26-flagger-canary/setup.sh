#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

ISTIO_VERSION=1.30.2
FLAGGER_CHART_VERSION=1.43.0

# --- Istio (minimal) + its addon Prometheus (Flagger's metrics source) ---------
ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && IARCH=arm64 || IARCH=amd64
curl -sL "https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-linux-${IARCH}.tar.gz" | tar xz -C /opt
ln -sf "/opt/istio-${ISTIO_VERSION}/bin/istioctl" /usr/local/bin/istioctl
istioctl install --set profile=minimal -y \
  --set values.pilot.resources.requests.cpu=100m \
  --set values.pilot.resources.requests.memory=512Mi \
  --set values.global.proxy.resources.requests.cpu=10m \
  --set values.global.proxy.resources.requests.memory=64Mi  # fit 2-vCPU lab VMs

kubectl apply -f "/opt/istio-${ISTIO_VERSION}/samples/addons/prometheus.yaml"

# --- Flagger (istio provider) ---------------------------------------------------
helm repo add flagger https://flagger.app
helm repo update flagger
helm upgrade --install flagger flagger/flagger \
  --namespace istio-system \
  --version ${FLAGGER_CHART_VERSION} \
  --set meshProvider=istio \
  --set metricsServer=http://prometheus.istio-system:9090 \
  --wait --timeout 10m

# --- The app to be canaried ------------------------------------------------------
kubectl create namespace release-bay --dry-run=client -o yaml | kubectl apply -f -
kubectl label ns release-bay istio-injection=enabled --overwrite

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: media-proxy
  namespace: release-bay
  labels:
    app: media-proxy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: media-proxy
  template:
    metadata:
      labels:
        app: media-proxy
    spec:
      containers:
        - name: media-proxy
          image: nginx:1.25
          ports:
            - name: http
              containerPort: 80
          resources:
            requests:
              cpu: 50m
              memory: 32Mi
---
# steady traffic through the mesh so request-success-rate has data
apiVersion: v1
kind: Pod
metadata:
  name: traffic-gen
  namespace: release-bay
  labels:
    app: traffic-gen
spec:
  containers:
    - name: curl
      image: curlimages/curl:8.9.1
      command: ["/bin/sh", "-c"]
      args:
        - while true; do curl -s --max-time 2 http://media-proxy.release-bay.svc >/dev/null 2>&1; sleep 0.3; done
EOF

kubectl -n release-bay rollout status deploy/media-proxy --timeout=300s || true
kubectl -n istio-system rollout status deploy/flagger --timeout=300s || true
kubectl -n istio-system rollout status deploy/prometheus --timeout=300s || true

touch /tmp/.cnpe-setup-done
