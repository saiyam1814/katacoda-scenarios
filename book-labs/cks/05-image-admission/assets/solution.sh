#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-05-image-admission
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
bash "$(dirname "$0")/base-solution.sh"
# Wait here for admission propagation; CHECK itself never waits for configuration.
for n in $(seq 1 30); do
 if ! kubectl -n book-cks-images run propagation-test --image=nginx:latest --dry-run=server >"$STATE_DIR/admission-propagation" 2>&1 && grep -q book-images "$STATE_DIR/admission-propagation"; then break; fi
 sleep 1
done
kubectl patch validatingadmissionpolicy book-images --type=json -p '[{"op":"add","path":"/spec/matchConstraints/resourceRules/0/resources/-","value":"pods/ephemeralcontainers"},{"op":"add","path":"/spec/validations/-","value":{"expression":"!has(object.spec.ephemeralContainers) || object.spec.ephemeralContainers.all(c, c.image.matches(\"^registry[.]k8s[.]io/[a-z0-9/._-]+@sha256:[a-f0-9]{64}$\"))","message":"Ephemeral images must use the approved registry and digest"}}]'
sleep 2

kubectl get validatingadmissionpolicy book-images -o yaml > "$WORK_DIR/cks28-policy.yaml"
printf "\n---\n" >> "$WORK_DIR/cks28-policy.yaml"
kubectl get validatingadmissionpolicybinding book-images -o yaml >> "$WORK_DIR/cks28-policy.yaml"
