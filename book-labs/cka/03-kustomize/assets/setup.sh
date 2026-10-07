#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-03-kustomize
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-kustomize
mkdir -p "$WORK_DIR/base" "$WORK_DIR/overlays/prod"
cat > "$WORK_DIR/base/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources: [deployment.yaml]
YAML
cat > "$WORK_DIR/base/deployment.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata: {name: web}
spec:
  replicas: 1
  selector:
    matchLabels: {app: web}
  template:
    metadata:
      labels: {app: web}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27.5
        ports: [{containerPort: 80}]
YAML
python3 - "$WORK_DIR/base" > "$STATE_DIR/base-hash" <<'PYHASH'
import hashlib,pathlib,sys
p=pathlib.Path(sys.argv[1]);print(hashlib.sha256(b''.join(x.read_bytes() for x in sorted(p.iterdir()))).hexdigest())
PYHASH
rm -f "$WORK_DIR/overlays/prod/kustomization.yaml"
setup_done
