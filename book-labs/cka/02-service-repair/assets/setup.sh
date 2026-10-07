#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-02-service-repair
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-service
kubectl -n book-cka-service create deployment web --image=nginx:1.28.0
kubectl -n book-cka-service run client --image=busybox:1.37.0 --command -- sleep 3600
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Service
metadata: {name: web, namespace: book-cka-service}
spec:
  selector: {app: wrong-app}
  ports: [{name: http, port: 80, targetPort: 8080}]
YAML
ready_deploy book-cka-service web
ready_pod book-cka-service client
kubectl -n book-cka-service get svc web -o jsonpath='{.spec.clusterIP}' > "$STATE_DIR/service-ip"
setup_done
