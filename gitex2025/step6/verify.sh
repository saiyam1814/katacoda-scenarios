#!/bin/bash
# step6/verify.sh – ensure Ingress host was updated and includes "killercoda"

# Grab the host from the first Ingress in the cluster
INGRESS_HOST=$(kubectl get ingress -A -o jsonpath='{.items[0].spec.rules[0].host}')

# Check for the "killercoda" substring
if [[ "$INGRESS_HOST" == *"killercoda"* ]]; then
  echo "✔ Ingress host correctly set to: $INGRESS_HOST"
  exit 0
else
  echo "✖ Ingress host '$INGRESS_HOST' does not contain 'killercoda'" >&2
  exit 1
fi