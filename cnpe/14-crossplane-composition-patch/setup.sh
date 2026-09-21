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
kubectl create namespace compose-sandbox --dry-run=client -o yaml | kubectl apply -f -
cat <<'EOF' | kubectl apply -f -
apiVersion: apiextensions.crossplane.io/v2
kind: CompositeResourceDefinition
metadata:
  name: xwebapps.platform.acme.dev
spec:
  scope: Namespaced
  group: platform.acme.dev
  names:
    kind: XWebApp
    plural: xwebapps
  versions:
  - name: v1alpha1
    served: true
    referenceable: true
    schema:
      openAPIV3Schema:
        type: object
        required:
        - spec
        properties:
          spec:
            type: object
            required:
            - appName
            - desiredReplicas
            - containerImage
            properties:
              appName:
                type: string
                minLength: 1
              desiredReplicas:
                type: integer
                minimum: 1
              containerImage:
                type: string
                minLength: 1
EOF
kubectl wait xrd/xwebapps.platform.acme.dev --for=condition=Established --timeout=120s
cat <<'EOF' > /root/composition.yaml
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  name: xwebapp-kubernetes
spec:
  compositeTypeRef:
    apiVersion: platform.acme.dev/v1alpha1
    kind: XWebApp
  mode: Pipeline
  pipeline:
  - step: patch-and-transform
    functionRef:
      name: function-patch-and-transform
    input:
      apiVersion: pt.fn.crossplane.io/v1beta1
      kind: Resources
      resources:
      - name: app-deployment
        base:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: placeholder
          spec:
            replicas: 1
            selector:
              matchLabels:
                app: placeholder
            template:
              metadata:
                labels:
                  app: placeholder
              spec:
                containers:
                - name: web
                  image: placeholder
                  ports:
                  - containerPort: 80
        patches:
        - type: FromCompositeFieldPath
          fromFieldPath: metadata.namespace
          toFieldPath: metadata.namespace
          policy:
            fromFieldPath: Required
        readinessChecks:
        - type: MatchCondition
          matchCondition:
            type: Available
            status: 'True'
      - name: app-service
        base:
          apiVersion: v1
          kind: Service
          metadata:
            name: placeholder
          spec:
            selector:
              app: placeholder
            ports:
            - port: 80
              targetPort: 80
        patches:
        - type: FromCompositeFieldPath
          fromFieldPath: metadata.namespace
          toFieldPath: metadata.namespace
          policy:
            fromFieldPath: Required
        - type: FromCompositeFieldPath
          fromFieldPath: spec.appName
          toFieldPath: metadata.name
          policy:
            fromFieldPath: Required
        - type: FromCompositeFieldPath
          fromFieldPath: spec.appName
          toFieldPath: spec.selector.app
          policy:
            fromFieldPath: Required
        readinessChecks:
        - type: None
EOF
# Complete the five app-deployment patches listed in the task.
cat <<'EOF' > /root/app-xr.yaml
apiVersion: platform.acme.dev/v1alpha1
kind: XWebApp
metadata:
  name: demo-site
  namespace: compose-sandbox
spec:
  crossplane:
    compositionRef:
      name: xwebapp-kubernetes
  appName: demo-site
  desiredReplicas: 2
  containerImage: nginx:1.25
EOF
touch /tmp/.cnpe-setup-done
