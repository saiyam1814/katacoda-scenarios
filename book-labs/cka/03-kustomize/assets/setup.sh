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
                "image": "nginx:1.27.5"
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

python3 - "$WORK_DIR/app/base" "$STATE_DIR/base-hashes.json" <<'PYHASH'
import hashlib,json,pathlib,sys
p=pathlib.Path(sys.argv[1]);pathlib.Path(sys.argv[2]).write_text(json.dumps({f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in p.iterdir() if f.is_file()}))
PYHASH
source "$(dirname -- "${BASH_SOURCE[0]}")/metrics.sh"
metrics_prepare
setup_done
