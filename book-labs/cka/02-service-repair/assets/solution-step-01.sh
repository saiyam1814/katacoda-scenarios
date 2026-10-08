#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-02-service-repair
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-service get svc web -o yaml
kubectl -n book-cka-service exec client -- cat /etc/resolv.conf
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl -n book-cka-service patch service web --type=merge -p '{"spec":{"selector":{"app":"web"},"ports":[{"port":80,"targetPort":80}]}}'
kubectl -n book-cka-service delete pod client --wait=true
kubectl -n book-cka-service run client --image=busybox:1.37.0 --command -- sleep 3600
ready_pod book-cka-service client
wait_until 30 kubectl -n book-cka-service exec client -- wget -qO- -T 2 http://web.book-cka-service.svc.cluster.local
printf '%s\n' 'Service selector did not match app=web; targetPort was 8080 instead of 80.' 'Client DNS used an invalid nameserver; recreated with ClusterFirst.' > "$WORK_DIR/causes.txt"
