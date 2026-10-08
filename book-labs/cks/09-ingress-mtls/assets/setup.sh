#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-09-ingress-mtls
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin

export DEBIAN_FRONTEND=noninteractive
command -v curl >/dev/null
mkdir -p "$STATE_DIR/downloads"
cd "$STATE_DIR/downloads"
if ! command -v helm >/dev/null; then
 curl -fL --retry 3 -O https://get.helm.sh/helm-v3.18.6-linux-amd64.tar.gz
 curl -fL --retry 3 -O https://get.helm.sh/helm-v3.18.6-linux-amd64.tar.gz.sha256sum
 sha256sum -c helm-v3.18.6-linux-amd64.tar.gz.sha256sum
 tar -xzf helm-v3.18.6-linux-amd64.tar.gz
 install linux-amd64/helm /usr/local/bin/helm
fi
helm upgrade --install book-traefik oci://ghcr.io/traefik/helm/traefik --version 41.6.1 --namespace book-ingress-system --create-namespace --set ingressClass.name=traefik --set service.spec.type=NodePort --set ports.web.nodePort=30080 --set ports.websecure.nodePort=30443 --set resources.requests.cpu=50m --set resources.requests.memory=64Mi --set resources.limits.memory=256Mi --wait --timeout 5m
reset_ns book-cks-ingress
for n in $(seq 1 30); do kubectl -n book-cks-ingress get serviceaccount default >/dev/null 2>&1 && break; sleep 1; done
kubectl -n book-cks-ingress get serviceaccount default >/dev/null
kubectl -n book-cks-ingress create configmap website --from-literal=index.html=book-tls-success
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: book-cks-ingress}
spec:
  replicas: 1
  selector: {matchLabels: {app: web}}
  template:
    metadata: {labels: {app: web}}
    spec:
      containers:
      - name: web
        image: nginx:1.28.0-alpine
        volumeMounts: [{name: site, mountPath: /usr/share/nginx/html, readOnly: true}]
      volumes: [{name: site, configMap: {name: website}}]
---
apiVersion: v1
kind: Service
metadata: {name: web, namespace: book-cks-ingress}
spec:
  selector: {app: web}
  ports: [{port: 80, targetPort: 80}]
YAML
ready_deploy book-cks-ingress web
kubectl get node -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' > "$WORK_DIR/node-ip.txt"
# Pinned upstream Istio release, actual sidecar control plane and certificate issuer.
curl -fL --retry 3 -O https://github.com/istio/istio/releases/download/1.31.1/istio-1.31.1-linux-amd64.tar.gz
curl -fL --retry 3 -O https://github.com/istio/istio/releases/download/1.31.1/istio-1.31.1-linux-amd64.tar.gz.sha256
printf '%s  istio-1.31.1-linux-amd64.tar.gz\n' "$(awk '{print $1}' istio-1.31.1-linux-amd64.tar.gz.sha256)" | sha256sum -c -
tar -xzf istio-1.31.1-linux-amd64.tar.gz
install istio-1.31.1/bin/istioctl /usr/local/bin/istioctl
istioctl install --set profile=minimal --set values.global.proxy.resources.requests.cpu=10m --set values.global.proxy.resources.requests.memory=64Mi --set values.global.proxy.resources.limits.memory=256Mi -y
reset_ns book-cks-mesh
for n in $(seq 1 30); do kubectl -n book-cks-mesh get serviceaccount default >/dev/null 2>&1 && break; sleep 1; done
kubectl -n book-cks-mesh get serviceaccount default >/dev/null
reset_ns book-cks-plain
for n in $(seq 1 30); do kubectl -n book-cks-plain get serviceaccount default >/dev/null 2>&1 && break; sleep 1; done
kubectl -n book-cks-plain get serviceaccount default >/dev/null
kubectl label namespace book-cks-mesh istio-injection=enabled
for sa in caller other server; do kubectl -n book-cks-mesh create serviceaccount "$sa"; done
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: server, namespace: book-cks-mesh, labels: {app: secure}}
spec:
  serviceAccountName: server
  containers: [{name: server, image: 'nginx:1.28.0-alpine', ports: [{containerPort: 80}]}]
---
apiVersion: v1
kind: Service
metadata: {name: secure, namespace: book-cks-mesh}
spec: {selector: {app: secure}, ports: [{name: http, port: 80, targetPort: 80}]}
YAML
for sa in caller other; do
 kubectl -n book-cks-mesh run "$sa" --image=curlimages/curl:8.12.1 --overrides="{\"spec\":{\"serviceAccountName\":\"$sa\"}}" --command -- sleep 3600
done
kubectl -n book-cks-plain run plain --image=curlimages/curl:8.12.1 --command -- sleep 3600
for pod in server caller other; do ready_pod book-cks-mesh "$pod"; done
ready_pod book-cks-plain plain
kubectl -n book-cks-mesh get pods -o json | python3 -c 'import json,sys;d=json.load(sys.stdin);assert all(any(c["name"]=="istio-proxy" for c in p["spec"].get("containers",[])+p["spec"].get("initContainers",[])) for p in d["items"])'
# Initially PERMISSIVE: prove the plaintext source really reaches the service.
kubectl -n book-cks-plain exec plain -- curl -fsS --max-time 5 http://secure.book-cks-mesh.svc.cluster.local/ > "$STATE_DIR/plain-before.html"

setup_done
