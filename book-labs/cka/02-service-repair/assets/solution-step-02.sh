#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-02-service-repair
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-incident get events --sort-by=.metadata.creationTimestamp
kubectl -n book-cka-incident set resources deployment/web --containers=web --requests=cpu=100m,memory=64Mi --limits=memory=128Mi
kubectl -n book-cka-incident set image deployment/web web=nginx:1.28.0
kubectl -n book-cka-incident patch deployment web --type=strategic -p '{"spec":{"template":{"spec":{"containers":[{"name":"web","envFrom":[{"configMapRef":{"name":"app-config"}}]}]}}}}'
kubectl -n book-cka-incident patch service web --type=merge -p '{"spec":{"ports":[{"port":80,"targetPort":"http"}]}}'
ready_deploy book-cka-incident web
kubectl -n book-cka-incident run client --image=busybox:1.37.0 --command -- sleep 3600
ready_pod book-cka-incident client
wait_until 30 kubectl -n book-cka-incident exec client -- wget -qO- -T 2 http://web.book-cka-incident.svc.cluster.local
printf '%s\n' 'Memory request 1Ti prevented scheduling; changed to 64Mi and limit128Mi.' 'Unavailable image replaced; missing ConfigMap reference repaired.' 'Service targetPort 8080 replaced by named http port.' 'Observed two available replicas and a real HTTP response.' > "$WORK_DIR/incident.txt"
