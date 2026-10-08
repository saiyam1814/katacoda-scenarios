#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-02-pod-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cks-psa
kubectl label namespace book-cks-psa pod-security.kubernetes.io/enforce=privileged --overwrite
: # outer setup owns readiness
