#!/bin/bash
# api-alpha: 1 + 2 = 3 replicas, labelled
[ "$(kubectl -n alpha-svc get deploy api-alpha -o jsonpath='{.spec.replicas}')" = "3" ] || exit 1
[ "$(kubectl -n alpha-svc get deploy api-alpha -o jsonpath='{.metadata.labels.cost\.platform\.io/adjusted}')" = "yes" ] || exit 1

# api-gamma: down to 2, labelled
[ "$(kubectl -n gamma-svc get deploy api-gamma -o jsonpath='{.spec.replicas}')" = "2" ] || exit 1
[ "$(kubectl -n gamma-svc get deploy api-gamma -o jsonpath='{.metadata.labels.cost\.platform\.io/adjusted}')" = "yes" ] || exit 1

# api-beta untouched: still 2 replicas, no adjusted label
[ "$(kubectl -n beta-svc get deploy api-beta -o jsonpath='{.spec.replicas}')" = "2" ] || exit 1
[ -z "$(kubectl -n beta-svc get deploy api-beta -o jsonpath='{.metadata.labels.cost\.platform\.io/adjusted}')" ] || exit 1

exit 0
