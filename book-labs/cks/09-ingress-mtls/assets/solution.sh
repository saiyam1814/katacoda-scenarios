#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-09-ingress-mtls
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
openssl req -x509 -nodes -newkey rsa:2048 -keyout "$WORK_DIR/book.key" -out "$WORK_DIR/book.crt" -days 2 -subj /CN=book.test -addext subjectAltName=DNS:book.test
chmod 600 "$WORK_DIR/book.key"
kubectl -n book-cks-ingress create secret tls book-tls --cert="$WORK_DIR/book.crt" --key="$WORK_DIR/book.key" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: book-cks-ingress
  annotations: {traefik.ingress.kubernetes.io/router.entrypoints: websecure}
spec:
  ingressClassName: traefik
  tls: [{hosts: [book.test], secretName: book-tls}]
  rules:
  - host: book.test
    http:
      paths:
      - path: /
        pathType: Prefix
        backend: {service: {name: web, port: {number: 80}}}
YAML
for n in $(seq 1 60); do curl --noproxy '*' --cacert "$WORK_DIR/book.crt" --resolve "book.test:30443:$(cat "$WORK_DIR/node-ip.txt")" -fsS https://book.test:30443/ && break; sleep 1; done
curl --noproxy '*' --cacert "$WORK_DIR/book.crt" --resolve "book.test:30443:$(cat "$WORK_DIR/node-ip.txt")" -fsS https://book.test:30443/
kubectl apply -f - <<'YAML'
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata: {name: strict, namespace: book-cks-mesh}
spec:
  mtls: {mode: STRICT}
---
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata: {name: caller-only, namespace: book-cks-mesh}
spec:
  selector: {matchLabels: {app: secure}}
  action: ALLOW
  rules:
  - from:
    - source: {principals: ['cluster.local/ns/book-cks-mesh/sa/caller']}
YAML
sleep 5
istioctl proxy-config clusters caller -n book-cks-mesh --fqdn secure.book-cks-mesh.svc.cluster.local -o json > "$WORK_DIR/mesh-clusters.json"
istioctl proxy-config secret caller -n book-cks-mesh -o json > "$WORK_DIR/mesh-certificates.json"
kubectl -n book-cks-mesh exec caller -c caller -- curl -fsS --max-time 5 http://secure/
