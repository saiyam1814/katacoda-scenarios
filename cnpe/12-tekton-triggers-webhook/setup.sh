#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

TEKTON_VERSION=v1.14.0
TRIGGERS_VERSION=v0.36.0
TKN_VERSION=0.45.0

kubectl apply -f "https://github.com/tektoncd/pipeline/releases/download/${TEKTON_VERSION}/release.yaml"
kubectl -n tekton-pipelines rollout status deploy/tekton-pipelines-webhook --timeout=600s || true

kubectl apply -f "https://github.com/tektoncd/triggers/releases/download/${TRIGGERS_VERSION}/release.yaml"
kubectl apply -f "https://github.com/tektoncd/triggers/releases/download/${TRIGGERS_VERSION}/interceptors.yaml"

ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && TARCH=aarch64 || TARCH=x86_64
curl -sL "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_${TARCH}.tar.gz" | tar xz -C /usr/local/bin tkn
chmod +x /usr/local/bin/tkn

kubectl create namespace ci-otter --dry-run=client -o yaml | kubectl apply -f -

# ServiceAccount the EventListener runs as, with the RBAC Triggers needs
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tekton-triggers
  namespace: ci-otter
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tekton-triggers-eventlistener
  namespace: ci-otter
subjects:
  - kind: ServiceAccount
    name: tekton-triggers
    namespace: ci-otter
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-roles
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tekton-triggers-eventlistener-ci-otter
subjects:
  - kind: ServiceAccount
    name: tekton-triggers
    namespace: ci-otter
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-clusterroles
EOF

kubectl -n tekton-pipelines rollout status deploy/tekton-triggers-controller --timeout=600s || true
kubectl -n tekton-pipelines rollout status deploy/tekton-triggers-webhook --timeout=600s || true
sleep 5

# The pipeline that already works via manual PipelineRuns
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: ship
  namespace: ci-otter
spec:
  params:
    - name: gitrevision
      type: string
  steps:
    - name: ship
      image: busybox:1.36
      script: |
        #!/bin/sh
        echo "building and shipping revision $(params.gitrevision)"
        sleep 2
        echo "shipped."
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: build-ship
  namespace: ci-otter
spec:
  params:
    - name: gitrevision
      type: string
      default: main
  tasks:
    - name: ship
      taskRef:
        name: ship
      params:
        - name: gitrevision
          value: $(params.gitrevision)
EOF

touch /tmp/.cnpe-setup-done
