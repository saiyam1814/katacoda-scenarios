#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-01-networkpolicy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
bash "$(dirname "$0")/base-solution.sh"
cat > "$WORK_DIR/deny-egress.yaml" <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: deny-client-egress, namespace: book-cks-egress}
spec:
  podSelector: {}
  policyTypes: [Egress]
YAML
kubectl apply -f "$WORK_DIR/deny-egress.yaml"
sleep 3
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: block-metadata, namespace: book-cks-metadata}
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
  - to:
    - ipBlock: {cidr: 0.0.0.0/0, except: [169.254.169.254/32]}
YAML
sleep 3
