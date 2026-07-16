#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

TEKTON_VERSION=v1.14.0
TKN_VERSION=0.45.0

kubectl apply -f "https://github.com/tektoncd/pipeline/releases/download/${TEKTON_VERSION}/release.yaml"

ARCH=$(uname -m); [ "$ARCH" = "aarch64" ] && TARCH=aarch64 || TARCH=x86_64
curl -sL "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_${TARCH}.tar.gz" | tar xz -C /usr/local/bin tkn
chmod +x /usr/local/bin/tkn

kubectl create namespace ci-otter --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pipeline-deployer
  namespace: ci-otter
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pipeline-deployer
  namespace: ci-otter
subjects:
  - kind: ServiceAccount
    name: default
    namespace: ci-otter
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pipeline-deployer
EOF

kubectl -n tekton-pipelines rollout status deploy/tekton-pipelines-controller --timeout=600s || true
kubectl -n tekton-pipelines rollout status deploy/tekton-pipelines-webhook --timeout=600s || true
sleep 5

# The existing pipeline: "build" an image ref, then deploy it. No security gate.
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: resolve-image
  namespace: ci-otter
spec:
  params:
    - name: image
      type: string
  results:
    - name: image-url
      description: The image this run ships
  steps:
    - name: resolve
      image: busybox:1.36
      script: |
        #!/bin/sh
        printf '%s' "$(params.image)" > "$(results.image-url.path)"
        echo "resolved image: $(params.image)"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: deploy-image
  namespace: ci-otter
spec:
  params:
    - name: image
      type: string
  steps:
    - name: deploy
      image: bitnamilegacy/kubectl:1.28.9
      script: |
        #!/bin/sh
        set -eu
        kubectl -n ci-otter create deployment shipped \
          --image="$(params.image)" --dry-run=client -o yaml | kubectl apply -f -
        echo "deployed $(params.image)"
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: build-ship
  namespace: ci-otter
spec:
  params:
    - name: image
      type: string
  tasks:
    - name: image
      taskRef:
        name: resolve-image
      params:
        - name: image
          value: $(params.image)
    - name: deploy
      taskRef:
        name: deploy-image
      runAfter: [image]
      params:
        - name: image
          value: $(tasks.image.results.image-url)
EOF

touch /tmp/.cnpe-setup-done
