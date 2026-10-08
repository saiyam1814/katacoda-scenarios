#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-02-service-repair
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cka-service
reset_ns book-cka-incident
rm -f "$WORK_DIR/causes.txt" "$WORK_DIR/incident.txt"
kubectl -n book-cka-service create deployment web --image=nginx:1.28.0
kubectl -n book-cka-service expose deployment web --port=80 --target-port=8080
kubectl -n book-cka-service patch service web --type=merge -p '{"spec":{"selector":{"app":"wrong"}}}'
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: client, namespace: book-cka-service}
spec:
  dnsPolicy: None
  dnsConfig: {nameservers: [203.0.113.53]}
  containers:
  - {name: client, image: 'busybox:1.37.0', command: [sleep, '3600']}
---
apiVersion: v1
kind: ConfigMap
metadata: {name: app-config, namespace: book-cka-incident}
data: {MODE: training}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: book-cka-incident}
spec:
  replicas: 2
  selector: {matchLabels: {app: web}}
  template:
    metadata: {labels: {app: web}}
    spec:
      containers:
      - name: web
        image: nginx:missing-book-incident
        ports: [{name: http, containerPort: 80}]
        envFrom: [{configMapRef: {name: missing-config}}]
        resources: {requests: {cpu: 100m, memory: 1Ti}, limits: {memory: 1Ti}}
        readinessProbe: {httpGet: {path: /, port: http}, periodSeconds: 3}
---
apiVersion: v1
kind: Service
metadata: {name: web, namespace: book-cka-incident}
spec:
  selector: {app: web}
  ports: [{port: 80, targetPort: 8080}]
YAML
ready_deploy book-cka-service web
ready_pod book-cka-service client
setup_done
