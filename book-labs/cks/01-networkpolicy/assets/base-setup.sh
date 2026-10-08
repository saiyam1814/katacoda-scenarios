#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-01-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
for namespace in book-cks-network book-cks-green book-cks-blue; do reset_ns "$namespace"; done
kubectl label namespace book-cks-green team=green --overwrite
kubectl label namespace book-cks-blue team=blue --overwrite
for app in api admin; do
  kubectl -n book-cks-network create deployment "$app" --image=nginx:1.28.0
  kubectl -n book-cks-network expose deployment "$app" --port=80
  ready_deploy book-cks-network "$app"
done
kubectl -n book-cks-green run trusted --labels=access=trusted --image=busybox:1.37.0 --command -- sleep 3600
kubectl -n book-cks-green run untrusted --labels=access=untrusted --image=busybox:1.37.0 --command -- sleep 3600
kubectl -n book-cks-blue run trusted --labels=access=trusted --image=busybox:1.37.0 --command -- sleep 3600
ready_pod book-cks-green trusted
ready_pod book-cks-green untrusted
ready_pod book-cks-blue trusted
api_ip=$(kubectl -n book-cks-network get svc api -o jsonpath='{.spec.clusterIP}')
kubectl -n book-cks-green exec trusted -- wget -T 3 -qO- "http://$api_ip" >/dev/null
# A canary detects a CNI that accepts policies without enforcing them.
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: setup-cni-check, namespace: book-cks-network}
spec:
  podSelector: {}
  policyTypes: [Ingress]
YAML
enforced=no
for attempt in $(seq 1 12); do
  if ! kubectl -n book-cks-green exec trusted -- wget -T 2 -qO- "http://$api_ip" >"$STATE_DIR/cni-probe" 2>&1; then enforced=yes; break; fi
  sleep 2
done
kubectl -n book-cks-network delete networkpolicy setup-cni-check
[[ "$enforced" == yes ]] || fail 'The CNI did not enforce deny ingress. Use a NetworkPolicy-capable CNI.'
# Recover baseline connectivity before presenting the task.
connected=no
for attempt in $(seq 1 20); do
  if kubectl -n book-cks-green exec trusted -- wget -T 2 -qO- "http://$api_ip" >/dev/null 2>&1; then connected=yes; break; fi
  sleep 1
done
[[ "$connected" == yes ]] || fail 'Baseline traffic did not recover after the CNI canary'
: # outer setup owns readiness
