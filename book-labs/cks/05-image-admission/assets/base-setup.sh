#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-05-image-admission
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin
reset_ns book-cks-images
reset_ns book-cks-images-outside
kubectl label namespace book-cks-images book-labs.example/image-policy=enforce --overwrite
kubectl delete validatingadmissionpolicybinding book-images --ignore-not-found
kubectl delete validatingadmissionpolicy book-images --ignore-not-found
kubectl api-resources --api-group=admissionregistration.k8s.io -o name > "$STATE_DIR/admission-apis"
python3 - "$STATE_DIR/admission-apis" <<'PYCHECK'
import pathlib,sys
s=pathlib.Path(sys.argv[1]).read_text();assert 'validatingadmissionpolicies' in s, 'ValidatingAdmissionPolicy is unavailable'
PYCHECK
: # outer setup owns readiness
