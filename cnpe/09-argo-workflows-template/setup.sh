#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

WF_VERSION=v3.7.2
ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && IARCH=arm64 || IARCH=amd64

# --- Argo Workflows controller ------------------------------------------------
kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argo -f "https://github.com/argoproj/argo-workflows/releases/download/${WF_VERSION}/install.yaml"

# argo CLI
curl -sL "https://github.com/argoproj/argo-workflows/releases/download/${WF_VERSION}/argo-linux-${IARCH}.gz" | gunzip > /usr/local/bin/argo
chmod +x /usr/local/bin/argo

# --- Namespaces ---------------------------------------------------------------
kubectl create namespace workflows --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace demo-reef --dry-run=client -o yaml | kubectl apply -f -

# --- ServiceAccount + RBAC for running workflows -------------------------------
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: workflow-runner
  namespace: workflows
---
# executor needs to report task results in its own namespace
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
# the deploy-kit template applies Deployments into demo-reef
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-manager
  namespace: demo-reef
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: workflow-runner-deployer
  namespace: demo-reef
subjects:
  - kind: ServiceAccount
    name: workflow-runner
    namespace: workflows
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployment-manager
EOF

kubectl -n argo rollout status deploy/workflow-controller --timeout=600s || true

touch /tmp/.cnpe-setup-done
