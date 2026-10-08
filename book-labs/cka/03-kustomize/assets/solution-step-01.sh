#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-03-kustomize
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
cat > "$WORK_DIR/app/overlays/prod/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namePrefix: prod-
replicas:
- name: web
  count: 3
images:
- name: nginx
  newTag: 1.28.0
labels:
- pairs:
    environment: production
  includeSelectors: true
YAML
kubectl kustomize "$WORK_DIR/app/overlays/prod" > "$WORK_DIR/app/rendered.yaml"
kubectl apply -k "$WORK_DIR/app/overlays/prod"
ready_deploy book-cka-kustomize prod-web
kubectl -n book-cka-kustomize run client --image=busybox:1.37.0 --restart=Never --command -- sleep 3600
ready_pod book-cka-kustomize client
