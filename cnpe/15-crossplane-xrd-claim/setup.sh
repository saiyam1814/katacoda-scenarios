#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -euo pipefail
export KUBECONFIG=/root/.kube/config
kubectl wait --for=condition=Ready nodes --all --timeout=180s
CROSSPLANE_CHART_VERSION=2.3.0
helm upgrade --install crossplane crossplane --repo https://charts.crossplane.io/stable   --namespace crossplane-system --create-namespace   --version "$CROSSPLANE_CHART_VERSION" --wait --timeout 10m
cat <<'EOF' | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Function
metadata:
  name: function-patch-and-transform
spec:
  package: xpkg.crossplane.io/crossplane-contrib/function-patch-and-transform:v0.8.2
EOF
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cnpe-compose-native
  labels:
    rbac.crossplane.io/aggregate-to-crossplane: 'true'
rules:
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - '*'
- apiGroups:
  - ''
  resources:
  - services
  - configmaps
  verbs:
  - '*'
EOF
kubectl wait function.pkg.crossplane.io/function-patch-and-transform --for=condition=Healthy --timeout=600s
kubectl create namespace team-apps --dry-run=client -o yaml | kubectl apply -f -
cat <<'EOF' > /root/bucket-composition.yaml
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  name: bucketapp-configmap
spec:
  compositeTypeRef:
    apiVersion: platform.example.io/v1alpha1
    kind: BucketApp
  mode: Pipeline
  pipeline:
  - step: patch-and-transform
    functionRef:
      name: function-patch-and-transform
    input:
      apiVersion: pt.fn.crossplane.io/v1beta1
      kind: Resources
      resources:
      - name: bucket-record
        base:
          apiVersion: v1
          kind: ConfigMap
          metadata:
            labels:
              platform.example.io/kind: bucket
          data:
            region: placeholder
            size: placeholder
        patches:
        - type: FromCompositeFieldPath
          fromFieldPath: metadata.name
          toFieldPath: metadata.name
          policy:
            fromFieldPath: Required
        - type: FromCompositeFieldPath
          fromFieldPath: metadata.namespace
          toFieldPath: metadata.namespace
          policy:
            fromFieldPath: Required
        - type: FromCompositeFieldPath
          fromFieldPath: spec.region
          toFieldPath: data.region
          policy:
            fromFieldPath: Required
        - type: FromCompositeFieldPath
          fromFieldPath: spec.size
          toFieldPath: data.size
          policy:
            fromFieldPath: Required
        readinessChecks:
        - type: None
EOF
touch /tmp/.cnpe-setup-done
