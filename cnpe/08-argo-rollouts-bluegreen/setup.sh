#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

ROLLOUTS_VERSION=v1.9.0
ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && IARCH=arm64 || IARCH=amd64

kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argo-rollouts -f "https://github.com/argoproj/argo-rollouts/releases/download/${ROLLOUTS_VERSION}/install.yaml"
curl -sL -o /usr/local/bin/kubectl-argo-rollouts "https://github.com/argoproj/argo-rollouts/releases/download/${ROLLOUTS_VERSION}/kubectl-argo-rollouts-linux-${IARCH}"
chmod +x /usr/local/bin/kubectl-argo-rollouts

kubectl create namespace shop-core --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: catalog
  namespace: shop-core
  labels:
    app: catalog
spec:
  replicas: 2
  selector:
    matchLabels:
      app: catalog
  template:
    metadata:
      labels:
        app: catalog
    spec:
      containers:
        - name: catalog
          image: nginx:1.25
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: catalog-active
  namespace: shop-core
spec:
  selector:
    app: catalog
  ports:
    - name: http
      port: 80
      targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: catalog-preview
  namespace: shop-core
spec:
  selector:
    app: catalog
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF

kubectl -n shop-core rollout status deploy/catalog --timeout=300s || true
kubectl -n argo-rollouts rollout status deploy/argo-rollouts --timeout=300s || true

touch /tmp/.cnpe-setup-done
