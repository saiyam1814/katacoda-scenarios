#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

# --- Prometheus (OpenCost's recommended minimal install) -------------------
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community

curl -sL https://raw.githubusercontent.com/opencost/opencost/develop/kubernetes/prometheus/extraScrapeConfigs.yaml -o /tmp/extraScrapeConfigs.yaml

helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace prometheus-system --create-namespace \
  --set prometheus-pushgateway.enabled=false \
  --set alertmanager.enabled=false \
  --set prometheus-node-exporter.enabled=false \
  -f /tmp/extraScrapeConfigs.yaml --wait --timeout 10m || true

# --- OpenCost ----------------------------------------------------------------
kubectl create namespace opencost --dry-run=client -o yaml | kubectl apply -f -
# pinned: kubernetes/opencost.yaml was removed from the develop branch (Helm-only now);
# v1.117.0 is the last release tag that still ships the standalone manifest
curl -sL https://raw.githubusercontent.com/opencost/opencost/v1.117.0/kubernetes/opencost.yaml -o /tmp/opencost.yaml
kubectl apply --namespace opencost -f /tmp/opencost.yaml

# --- kubectl-cost plugin -------------------------------------------------------
ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && ARCH=arm64; [ "$ARCH" = "x86_64" ] && ARCH=amd64
KCOST_VERSION=$(curl -s https://api.github.com/repos/kubecost/kubectl-cost/releases/latest | grep tag_name | cut -d'"' -f4)
curl -sL "https://github.com/kubecost/kubectl-cost/releases/download/${KCOST_VERSION}/kubectl-cost-linux-${ARCH}.tar.gz" | tar -xz -C /tmp
mv /tmp/kubectl-cost /usr/local/bin/kubectl-cost && chmod +x /usr/local/bin/kubectl-cost || true

# --- The three services to right-size ---------------------------------------
for ns in alpha-svc beta-svc gamma-svc; do
  kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
done

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-alpha
  namespace: alpha-svc
spec:
  replicas: 1
  selector: { matchLabels: { app: api-alpha } }
  template:
    metadata: { labels: { app: api-alpha } }
    spec:
      containers:
        - name: app
          image: nginx:1.27-alpine
          resources:
            requests: { cpu: 25m, memory: 32Mi }
            limits: { cpu: 50m, memory: 64Mi }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-beta
  namespace: beta-svc
spec:
  replicas: 2
  selector: { matchLabels: { app: api-beta } }
  template:
    metadata: { labels: { app: api-beta } }
    spec:
      containers:
        - name: app
          image: nginx:1.27-alpine
          resources:
            requests: { cpu: 100m, memory: 128Mi }
            limits: { cpu: 200m, memory: 256Mi }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gamma
  namespace: gamma-svc
spec:
  replicas: 3
  selector: { matchLabels: { app: api-gamma } }
  template:
    metadata: { labels: { app: api-gamma } }
    spec:
      containers:
        - name: app
          image: nginx:1.27-alpine
          resources:
            requests: { cpu: 300m, memory: 384Mi }
            limits: { cpu: 400m, memory: 512Mi }
EOF

kubectl -n opencost rollout status deploy/opencost --timeout=300s || true

touch /tmp/.cnpe-setup-done
