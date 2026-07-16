#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

TEKTON_VERSION=v1.14.0
TKN_VERSION=0.45.0

# --- Tekton Pipelines ----------------------------------------------------------
kubectl apply -f "https://github.com/tektoncd/pipeline/releases/download/${TEKTON_VERSION}/release.yaml"

# tkn CLI
ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && TARCH=aarch64 || TARCH=x86_64
curl -sL "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_${TARCH}.tar.gz" | tar xz -C /usr/local/bin tkn
chmod +x /usr/local/bin/tkn

kubectl create namespace pipeline-lab --dry-run=client -o yaml | kubectl apply -f -

# RBAC: TaskRun pods (default SA) may manage Deployments in pipeline-lab
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pipeline-deployer
  namespace: pipeline-lab
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pipeline-deployer
  namespace: pipeline-lab
subjects:
  - kind: ServiceAccount
    name: default
    namespace: pipeline-lab
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pipeline-deployer
EOF

kubectl -n tekton-pipelines rollout status deploy/tekton-pipelines-controller --timeout=600s || true
kubectl -n tekton-pipelines rollout status deploy/tekton-pipelines-webhook --timeout=600s || true
sleep 5

# --- The existing pipeline: build and package ---------------------------------
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build
  namespace: pipeline-lab
spec:
  steps:
    - name: compile
      image: busybox:1.36
      script: |
        #!/bin/sh
        echo "compiling release artifacts..."
        sleep 2
        echo "done"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: package
  namespace: pipeline-lab
spec:
  results:
    - name: manifest
      description: Rendered Kubernetes manifest for the release
  steps:
    - name: render
      image: busybox:1.36
      script: |
        #!/bin/sh
        cat > "$(results.manifest.path)" <<'MANIFEST'
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: compiled-web
          namespace: pipeline-lab
          labels:
            release: compile-release
        spec:
          replicas: 1
          selector:
            matchLabels:
              app: compiled-web
          template:
            metadata:
              labels:
                app: compiled-web
            spec:
              containers:
                - name: web
                  image: nginx:1.27-alpine
                  ports:
                    - containerPort: 80
        MANIFEST
        echo "manifest rendered"
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: compile-release
  namespace: pipeline-lab
spec:
  tasks:
    - name: build
      taskRef:
        name: build
    - name: package
      taskRef:
        name: package
EOF

touch /tmp/.cnpe-setup-done
