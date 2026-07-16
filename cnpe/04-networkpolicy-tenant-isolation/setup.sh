#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

# Tenant namespace with the API workload
kubectl create namespace tenant-red --dry-run=client -o yaml | kubectl apply -f -

# Edge gateway namespace (labelled) and an unrelated squad namespace (not labelled)
kubectl create namespace ingress-gw --dry-run=client -o yaml | kubectl apply -f -
kubectl label ns ingress-gw purpose=edge --overwrite
kubectl create namespace other-squad --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: tenant-red
  labels:
    app: api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
        - name: api
          image: registry.k8s.io/e2e-test-images/agnhost:2.47
          args: ["netexec", "--http-port=8080"]
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: tenant-red
spec:
  selector:
    app: api
  ports:
    - port: 8080
      targetPort: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: edge-client
  namespace: ingress-gw
  labels:
    app: edge-client
spec:
  containers:
    - name: curl
      image: curlimages/curl:8.9.1
      command: ["sleep", "infinity"]
---
apiVersion: v1
kind: Pod
metadata:
  name: squad-client
  namespace: other-squad
  labels:
    app: squad-client
spec:
  containers:
    - name: curl
      image: curlimages/curl:8.9.1
      command: ["sleep", "infinity"]
EOF

kubectl -n tenant-red rollout status deploy/api --timeout=180s || true
kubectl -n ingress-gw wait --for=condition=ready pod/edge-client --timeout=120s || true
kubectl -n other-squad wait --for=condition=ready pod/squad-client --timeout=120s || true

touch /tmp/.cnpe-setup-done
