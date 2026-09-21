#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -euxo pipefail

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

# --- Prometheus (OpenCost's recommended minimal install) -------------------
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community

curl -fsSL --retry 2 https://raw.githubusercontent.com/opencost/opencost/develop/kubernetes/prometheus/extraScrapeConfigs.yaml -o /tmp/extraScrapeConfigs.yaml

helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace prometheus-system --create-namespace \
  --set prometheus-pushgateway.enabled=false \
  --set alertmanager.enabled=false \
  --set prometheus-node-exporter.enabled=false \
  -f /tmp/extraScrapeConfigs.yaml --wait --timeout 10m

# --- OpenCost ----------------------------------------------------------------
kubectl create namespace opencost --dry-run=client -o yaml | kubectl apply -f -
# This release contains the standalone manifest used by this lab. Its image tags
# are mutable; the manifest version is not an image-version pin.
curl -fsSL --retry 2 https://raw.githubusercontent.com/opencost/opencost/v1.117.0/kubernetes/opencost.yaml -o /tmp/opencost.yaml
kubectl apply --namespace opencost -f /tmp/opencost.yaml

# --- kubectl-cost plugin -------------------------------------------------------
# v0.6.6 publishes Linux amd64, but no Linux arm64 archive. The UI and API do
# not depend on this optional client.
if [ "$(uname -m)" = x86_64 ]; then
  if curl -fsSL --retry 2 https://github.com/kubecost/kubectl-cost/releases/download/v0.6.6/kubectl-cost-linux-amd64.tar.gz -o /tmp/kubectl-cost.tar.gz &&
     tar -xzf /tmp/kubectl-cost.tar.gz -C /tmp &&
     install -m 755 /tmp/kubectl-cost /usr/local/bin/kubectl-cost; then
    echo 'Installed optional kubectl-cost v0.6.6'
  else
    echo 'kubectl-cost installation failed; use the OpenCost UI or allocation API.'
  fi
else
  echo 'No Linux kubectl-cost archive for this architecture; use the OpenCost UI or allocation API.'
fi

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

kubectl -n opencost rollout status deploy/opencost --timeout=300s
for ns in alpha-svc beta-svc gamma-svc; do
  kubectl -n "$ns" rollout status deployment --timeout=300s
done

touch /tmp/.cnpe-setup-done
