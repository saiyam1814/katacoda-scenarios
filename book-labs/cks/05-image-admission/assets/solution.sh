#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-05-image-admission
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl apply -f - <<'YAML'
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata: {name: book-images}
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
    - apiGroups: ['']
      apiVersions: [v1]
      operations: [CREATE, UPDATE]
      resources: [pods]
  validations:
  - expression: "object.spec.containers.all(c, c.image.matches('^registry[.]k8s[.]io/[a-z0-9/._-]+@sha256:[a-f0-9]{64}$'))"
    message: Regular container images must use registry.k8s.io and a sha256 digest
  - expression: "!has(object.spec.initContainers) || object.spec.initContainers.all(c, c.image.matches('^registry[.]k8s[.]io/[a-z0-9/._-]+@sha256:[a-f0-9]{64}$'))"
    message: Init container images must use registry.k8s.io and a sha256 digest
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata: {name: book-images}
spec:
  policyName: book-images
  validationActions: [Deny]
  matchResources:
    namespaceSelector:
      matchLabels: {book-labs.example/image-policy: enforce}
YAML
