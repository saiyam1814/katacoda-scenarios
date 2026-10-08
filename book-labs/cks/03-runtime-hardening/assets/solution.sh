#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-03-runtime-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
bash "$(dirname "$0")/base-solution.sh"
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: book-cks-readonly}
spec:
  replicas: 1
  selector: {matchLabels: {app: web}}
  template:
    metadata: {labels: {app: web}}
    spec:
      securityContext: {runAsUser: 1000, runAsGroup: 1000, runAsNonRoot: true, fsGroup: 1000, seccompProfile: {type: RuntimeDefault}}
      containers:
      - name: web
        image: busybox:1.37.0
        command: [httpd, -f, -p, '8080', -h, /etc]
        ports: [{containerPort: 8080}]
        securityContext: {allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, capabilities: {drop: [ALL]}}
        volumeMounts: [{name: scratch, mountPath: /tmp}]
      volumes: [{name: scratch, emptyDir: {}}]
---
apiVersion: v1
kind: Service
metadata: {name: web, namespace: book-cks-readonly}
spec:
  selector: {app: web}
  ports: [{port: 8080, targetPort: 8080}]
YAML
ready_deploy book-cks-readonly web
cat > /var/lib/kubelet/seccomp/profiles/book-deny-chmod.json <<'JSON'
{"defaultAction":"SCMP_ACT_ALLOW","syscalls":[{"names":["chmod","fchmod","fchmodat"],"action":"SCMP_ACT_ERRNO","errnoRet":1}]}
JSON
kubectl -n book-cks-seccomp delete pod demo --ignore-not-found
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: demo, namespace: book-cks-seccomp}
spec:
  securityContext:
    seccompProfile: {type: Localhost, localhostProfile: profiles/book-deny-chmod.json}
  containers:
  - name: demo
    image: busybox:1.37.0
    command: [sleep, '3600']
YAML
ready_pod book-cks-seccomp demo
