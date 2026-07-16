#!/bin/bash
# default-cpu-pod exists and got the 50m defaults injected
REQ=$(kubectl -n squad-nebula get pod default-cpu-pod -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
LIM=$(kubectl -n squad-nebula get pod default-cpu-pod -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
[ "$REQ" = "50m" ] || exit 1
[ "$LIM" = "50m" ] || exit 1

# over-max-cpu must NOT exist (it was rejected by the LimitRange)
kubectl -n squad-nebula get pod over-max-cpu >/dev/null 2>&1 && exit 1

exit 0
