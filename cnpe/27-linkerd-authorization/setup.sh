#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

LINKERD_VERSION=edge-26.6.3
GATEWAY_API_VERSION=v1.2.1

# --- linkerd CLI ------------------------------------------------------------------
ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && LARCH=arm64 || LARCH=amd64
curl -sL -o /usr/local/bin/linkerd \
  "https://github.com/linkerd/linkerd2/releases/download/${LINKERD_VERSION}/linkerd2-cli-${LINKERD_VERSION}-linux-${LARCH}"
chmod +x /usr/local/bin/linkerd

# --- control plane ------------------------------------------------------------------
# modern linkerd requires the Gateway API CRDs before its own
kubectl apply --server-side -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml"
linkerd install --crds | kubectl apply -f -
linkerd install --set proxyInit.runAsRoot=true | kubectl apply -f -
linkerd check --wait 10m || true

# --- the cast: protected service + two callers with different identities -------------
for ns in payments web batch; do
  kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
  kubectl annotate namespace "$ns" linkerd.io/inject=enabled --overwrite
done

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
            - name: http
              containerPort: 8080
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
