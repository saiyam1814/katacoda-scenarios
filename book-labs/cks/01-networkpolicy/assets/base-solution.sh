#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-01-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny-ingress, namespace: book-cks-network}
spec:
  podSelector: {}
  policyTypes: [Ingress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-green-trusted, namespace: book-cks-network}
spec:
  podSelector:
    matchLabels: {app: api}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector:
        matchLabels: {team: green}
      podSelector:
        matchLabels: {access: trusted}
    # A separate peer is OR, while selectors in the peer above are AND.
    # Without namespaceSelector this Pod selector is local to this namespace.
    - podSelector:
        matchLabels: {demo: test}
    ports: [{protocol: TCP, port: 80}]
YAML
