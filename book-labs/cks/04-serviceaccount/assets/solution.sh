#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-04-serviceaccount
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
bash "$(dirname "$0")/base-solution.sh"
kubectl -n book-cks-secrets delete rolebinding excess --ignore-not-found
kubectl -n book-cks-secrets create role database-reader --verb=get --resource=secrets --resource-name=database --dry-run=client -o yaml | kubectl apply -f -
kubectl -n book-cks-secrets create role deploy-creator --verb=create --resource=deployments.apps --dry-run=client -o yaml | kubectl apply -f -
for role in database-reader deploy-creator; do kubectl -n book-cks-secrets create rolebinding "$role" --role="$role" --serviceaccount=book-cks-secrets:sam --dry-run=client -o yaml | kubectl apply -f -; done
kubectl -n book-cks-secrets delete pod consumer --ignore-not-found
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: consumer, namespace: book-cks-secrets}
spec:
  automountServiceAccountToken: false
  containers:
  - name: consumer
    image: busybox:1.37.0
    command: [sleep, '3600']
    env:
    - name: DB_USER
      valueFrom: {secretKeyRef: {name: database, key: username}}
    volumeMounts: [{name: db, mountPath: /etc/db, readOnly: true}]
  volumes:
  - name: db
    secret:
      secretName: database
      items: [{key: password, path: password}]
YAML
ready_pod book-cks-secrets consumer
token=$(kubectl -n book-cks-identity create token reader --duration=10m --audience="$(cat "$STATE_DIR/token-audience")")
server=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
kubectl config view --raw --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > "$WORK_DIR/ca.crt"
rm -f "$WORK_DIR/reader.kubeconfig"
umask 077
kubectl --kubeconfig="$WORK_DIR/reader.kubeconfig" config set-cluster lab --server="$server" --certificate-authority="$WORK_DIR/ca.crt" --embed-certs=true
kubectl --kubeconfig="$WORK_DIR/reader.kubeconfig" config set-credentials reader --token="$token"
kubectl --kubeconfig="$WORK_DIR/reader.kubeconfig" config set-context reader --cluster=lab --user=reader --namespace=book-cks-identity
kubectl --kubeconfig="$WORK_DIR/reader.kubeconfig" config use-context reader
unset token
kubectl --kubeconfig="$WORK_DIR/reader.kubeconfig" get configmap settings
