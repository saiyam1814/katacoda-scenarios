#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

ISTIO_VERSION=1.30.2

ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && IARCH=arm64 || IARCH=amd64
curl -sL "https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-linux-${IARCH}.tar.gz" | tar xz -C /opt
ln -sf "/opt/istio-${ISTIO_VERSION}/bin/istioctl" /usr/local/bin/istioctl
istioctl install --set profile=minimal -y

# payments: the protected service; web: the legit caller; batch: the intruder
kubectl create namespace payments --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace web --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace batch --dry-run=client -o yaml | kubectl apply -f -
kubectl label ns payments istio-injection=enabled --overwrite
kubectl label ns web istio-injection=enabled --overwrite
kubectl label ns batch istio-injection=enabled --overwrite

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkout
  namespace: payments
  labels:
    app: checkout
spec:
  replicas: 1
  selector:
    matchLabels:
      app: checkout
  template:
    metadata:
      labels:
        app: checkout
    spec:
      containers:
        - name: checkout
          image: registry.k8s.io/e2e-test-images/agnhost:2.47
          args: ["netexec", "--http-port=8080"]
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: checkout
  namespace: payments
spec:
  selector:
    app: checkout
  ports:
    - name: http
      port: 8080
      targetPort: 8080
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: storefront
  namespace: web
---
apiVersion: v1
kind: Pod
metadata:
  name: storefront
  namespace: web
  labels:
    app: storefront
spec:
  serviceAccountName: storefront
  containers:
    - name: curl
      image: curlimages/curl:8.9.1
      command: ["sleep", "infinity"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: reporting
  namespace: batch
---
apiVersion: v1
kind: Pod
metadata:
  name: reporting
  namespace: batch
  labels:
    app: reporting
spec:
  serviceAccountName: reporting
  containers:
    - name: curl
      image: curlimages/curl:8.9.1
      command: ["sleep", "infinity"]
EOF

kubectl -n payments rollout status deploy/checkout --timeout=300s || true
kubectl -n web wait --for=condition=ready pod/storefront --timeout=180s || true
kubectl -n batch wait --for=condition=ready pod/reporting --timeout=180s || true

touch /tmp/.cnpe-setup-done
