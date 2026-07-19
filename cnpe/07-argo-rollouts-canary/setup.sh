#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

ISTIO_VERSION=1.30.2
ROLLOUTS_VERSION=v1.9.0

# --- Istio (minimal = istiod only) ------------------------------------------
ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && IARCH=arm64 || IARCH=amd64
curl -sL "https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-linux-${IARCH}.tar.gz" | tar xz -C /opt
ln -sf "/opt/istio-${ISTIO_VERSION}/bin/istioctl" /usr/local/bin/istioctl
istioctl install --set profile=minimal -y \
  --set values.pilot.resources.requests.cpu=100m \
  --set values.pilot.resources.requests.memory=512Mi \
  --set values.global.proxy.resources.requests.cpu=10m \
  --set values.global.proxy.resources.requests.memory=64Mi  # fit 2-vCPU lab VMs

# --- Argo Rollouts controller + kubectl plugin --------------------------------
kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argo-rollouts -f "https://github.com/argoproj/argo-rollouts/releases/download/${ROLLOUTS_VERSION}/install.yaml"
curl -sL -o /usr/local/bin/kubectl-argo-rollouts "https://github.com/argoproj/argo-rollouts/releases/download/${ROLLOUTS_VERSION}/kubectl-argo-rollouts-linux-${IARCH}"
chmod +x /usr/local/bin/kubectl-argo-rollouts

# --- The release-bay namespace: existing app, services, VirtualService --------
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
  replicas: 1
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
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: media-proxy
  namespace: release-bay
spec:
  selector:
    app: media-proxy
  ports:
    - name: http
      port: 80
      targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: media-proxy-stable
  namespace: release-bay
spec:
  selector:
    app: media-proxy
  ports:
    - name: http
      port: 80
      targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: media-proxy-canary
  namespace: release-bay
spec:
  selector:
    app: media-proxy
  ports:
    - name: http
      port: 80
      targetPort: 80
---
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: media-proxy
  namespace: release-bay
spec:
  hosts:
    - media-proxy
  http:
    - name: primary
      route:
        - destination:
            host: media-proxy-stable
          weight: 100
        - destination:
            host: media-proxy-canary
          weight: 0
---
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
      # nginx 404 pages carry the version in the body; Istio's sidecar rewrites the
      # Server header (always "envoy") but never the body - so this shows the true mix
      args:
        - while true; do curl -s --max-time 2 http://media-proxy.release-bay.svc/give-me-your-version 2>/dev/null | grep -o "nginx/[0-9.]*"; sleep 0.5; done
EOF

kubectl -n release-bay rollout status deploy/media-proxy --timeout=300s || true
kubectl -n argo-rollouts rollout status deploy/argo-rollouts --timeout=300s || true

touch /tmp/.cnpe-setup-done
