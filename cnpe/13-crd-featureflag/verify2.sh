#!/bin/bash
# The contract CR exists with the right values
[ "$(kubectl -n flags-lab get featureflag checkout-express -o jsonpath='{.spec.key}' 2>/dev/null)" = "checkout.express" ] || exit 1
[ "$(kubectl -n flags-lab get featureflag checkout-express -o jsonpath='{.spec.enabled}')" = "true" ] || exit 1
[ "$(kubectl -n flags-lab get featureflag checkout-express -o jsonpath='{.spec.rolloutPercent}')" = "25" ] || exit 1

# Short name resolves
kubectl get ff -n flags-lab >/dev/null 2>&1 || exit 1

# The invalid ones must NOT exist
kubectl -n flags-lab get featureflag bad-percent >/dev/null 2>&1 && exit 1
kubectl -n flags-lab get featureflag no-enabled >/dev/null 2>&1 && exit 1

exit 0
