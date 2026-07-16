#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

GATEKEEPER_VERSION=v3.23.0

kubectl apply -f "https://raw.githubusercontent.com/open-policy-agent/gatekeeper/${GATEKEEPER_VERSION}/deploy/gatekeeper.yaml"

kubectl -n gatekeeper-system rollout status deploy/gatekeeper-controller-manager --timeout=600s || true
kubectl -n gatekeeper-system rollout status deploy/gatekeeper-audit --timeout=600s || true

# Wait for the ConstraintTemplate CRD to be served
kubectl wait --for=condition=established crd/constrainttemplates.templates.gatekeeper.sh --timeout=120s || true
sleep 5

# The ConstraintTemplate is given (the exam pre-installs it too)
cat <<'EOF' | kubectl apply -f -
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: forbidfloatingtag
spec:
  crd:
    spec:
      names:
        kind: ForbidFloatingTag
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package forbidfloatingtag

        containers(obj) = c {
          c := obj.spec.containers
        }
        containers(obj) = c {
          c := obj.spec.template.spec.containers
        }
        containers(obj) = c {
          c := obj.spec.jobTemplate.spec.template.spec.containers
        }

        violation[{"msg": msg}] {
          some i
          cs := containers(input.review.object)
          img := cs[i].image
          endswith(img, ":latest")
          msg := sprintf("container <%v> uses floating tag :latest in image <%v>", [cs[i].name, img])
        }

        violation[{"msg": msg}] {
          some i
          cs := containers(input.review.object)
          img := cs[i].image
          not contains_tag(img)
          msg := sprintf("container <%v> uses an untagged image <%v> - pin a tag", [cs[i].name, img])
        }

        contains_tag(img) {
          contains(img, "@sha256:")
        }
        contains_tag(img) {
          parts := split(img, "/")
          last := parts[count(parts) - 1]
          contains(last, ":")
        }
EOF

# Wait until the template's constraint kind is served
for i in $(seq 1 30); do
  kubectl get crd forbidfloatingtag.constraints.gatekeeper.sh >/dev/null 2>&1 && break
  sleep 2
done

kubectl create namespace tag-lab --dry-run=client -o yaml | kubectl apply -f -

touch /tmp/.cnpe-setup-done
