#!/bin/bash
# offenders labelled
[ "$(kubectl get ns fleet-2 -o jsonpath='{.metadata.labels.secops\.acme/needs-hardening}')" = "true" ] || exit 1
[ "$(kubectl get ns fleet-4 -o jsonpath='{.metadata.labels.secops\.acme/needs-hardening}')" = "true" ] || exit 1

# clean namespaces NOT labelled
[ -z "$(kubectl get ns fleet-1 -o jsonpath='{.metadata.labels.secops\.acme/needs-hardening}')" ] || exit 1
[ -z "$(kubectl get ns fleet-3 -o jsonpath='{.metadata.labels.secops\.acme/needs-hardening}')" ] || exit 1

# deployments not patched to silence warnings: hostPath and hostNetwork still present
kubectl -n fleet-2 get deploy log-scraper -o json | grep -q hostPath || exit 1
[ "$(kubectl -n fleet-4 get deploy net-probe -o jsonpath='{.spec.template.spec.hostNetwork}')" = "true" ] || exit 1

exit 0
