#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-03-kustomize
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-kustomize
mkdir -p "$WORK_DIR/app/base" "$WORK_DIR/app/overlays/prod"
cat > "$WORK_DIR/app/base/resources.json" <<'JSON'
{
  "apiVersion": "v1",
  "kind": "List",
  "items": [
    {
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "metadata": {
        "name": "web",
        "namespace": "book-cka-kustomize"
      },
      "spec": {
        "replicas": 1,
        "selector": {
          "matchLabels": {
            "app": "web"
          }
        },
        "template": {
          "metadata": {
            "labels": {
              "app": "web"
            }
          },
          "spec": {
            "containers": [
              {
                "name": "web",
                "image": "nginx:1.28.0"
              }
            ]
          }
        }
      }
    },
    {
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": {
        "name": "web",
        "namespace": "book-cka-kustomize"
      },
      "spec": {
        "selector": {
          "app": "web"
        },
        "ports": [
          {
            "port": 80,
            "targetPort": 80
          }
        ]
      }
    }
  ]
}
JSON
cat > "$WORK_DIR/app/base/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- resources.json
YAML
source "$(dirname -- "${BASH_SOURCE[0]}")/metrics.sh"
metrics_prepare
setup_done
