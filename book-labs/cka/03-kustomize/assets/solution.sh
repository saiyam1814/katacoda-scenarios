#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-03-kustomize
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
cat > "$WORK_DIR/overlays/prod/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources: [../../base]
namespace: book-cka-kustomize
namePrefix: prod-
replicas:
- name: web
  count: 3
images:
- name: nginx
  newTag: 1.28.0
labels:
- pairs: {environment: prod}
  includeTemplates: true
YAML
kubectl apply -k "$WORK_DIR/overlays/prod"
ready_deploy book-cka-kustomize prod-web
