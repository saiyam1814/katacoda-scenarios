#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

WF_VERSION=v3.7.2
ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && IARCH=arm64 || IARCH=amd64

kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argo -f "https://github.com/argoproj/argo-workflows/releases/download/${WF_VERSION}/install.yaml"

curl -sL "https://github.com/argoproj/argo-workflows/releases/download/${WF_VERSION}/argo-linux-${IARCH}.gz" | gunzip > /usr/local/bin/argo
chmod +x /usr/local/bin/argo

kubectl create namespace workflows --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace stage-coral --dry-run=client -o yaml | kubectl apply -f -

# The app the ready-check will wait on
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkout-api
  namespace: stage-coral
  labels:
    app: checkout-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: checkout-api
  template:
    metadata:
      labels:
        app: checkout-api
    spec:
      containers:
        - name: api
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
EOF

# RBAC: workflow-runner runs workflow pods and may restart/inspect the staging deploy
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: workflow-runner
  namespace: workflows
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: workflow-executor
  namespace: workflows
rules:
  - apiGroups: ["argoproj.io"]
    resources: ["workflowtaskresults"]
    verbs: ["create", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: workflow-runner-executor
  namespace: workflows
subjects:
  - kind: ServiceAccount
    name: workflow-runner
    namespace: workflows
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: workflow-executor
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: stage-deployer
  namespace: stage-coral
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: workflow-runner-stage
  namespace: stage-coral
subjects:
  - kind: ServiceAccount
    name: workflow-runner
    namespace: workflows
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: stage-deployer
EOF

# The existing pipeline definition the user must edit
cat <<'EOF' > /root/release-checker.yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: release-checker-
  namespace: workflows
spec:
  entrypoint: main
  serviceAccountName: workflow-runner
  templates:
    - name: main
      steps:
        - - name: deploy
            template: deploy
        - - name: test
            template: test

    - name: deploy
      container:
        image: rancher/kubectl:v1.28.0
        command: [kubectl]
        args: [-n, stage-coral, rollout, restart, deploy/checkout-api]

    - name: test
      container:
        image: busybox:1.36
        command: [sh, -c]
        args:
          - echo "smoke tests passed"
EOF

kubectl -n argo rollout status deploy/workflow-controller --timeout=600s || true
kubectl -n stage-coral rollout status deploy/checkout-api --timeout=300s || true

touch /tmp/.cnpe-setup-done
