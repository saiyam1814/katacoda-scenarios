#!/bin/bash
kubectl -n tenant-red get networkpolicy deny-all-ingress >/dev/null 2>&1 || exit 1

# Selects all pods
SEL=$(kubectl -n tenant-red get networkpolicy deny-all-ingress -o jsonpath='{.spec.podSelector}')
[ "$SEL" = "{}" ] || exit 1

# Ingress is policed with no allow rules
kubectl -n tenant-red get networkpolicy deny-all-ingress -o jsonpath='{.spec.policyTypes}' | grep -q "Ingress" || exit 1
RULES=$(kubectl -n tenant-red get networkpolicy deny-all-ingress -o jsonpath='{.spec.ingress}')
[ -z "$RULES" ] || exit 1

exit 0
