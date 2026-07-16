#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

CROSSPLANE_CHART_VERSION=1.20.0
PROVIDER_K8S_VERSION=v0.18.0

# --- Crossplane core -----------------------------------------------------------
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update crossplane-stable
helm upgrade --install crossplane crossplane-stable/crossplane \
  --namespace crossplane-system --create-namespace \
  --version ${CROSSPLANE_CHART_VERSION} --wait --timeout 10m

# --- provider-kubernetes with a fixed ServiceAccount -----------------------------
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1beta1
kind: DeploymentRuntimeConfig
metadata:
  name: provider-kubernetes
spec:
  serviceAccountTemplate:
    metadata:
      name: provider-kubernetes
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-kubernetes
spec:
  package: xpkg.crossplane.io/crossplane-contrib/provider-kubernetes:${PROVIDER_K8S_VERSION}
  runtimeConfigRef:
    apiVersion: pkg.crossplane.io/v1beta1
    kind: DeploymentRuntimeConfig
    name: provider-kubernetes
EOF

kubectl wait provider.pkg.crossplane.io/provider-kubernetes --for=condition=Healthy --timeout=600s || true

# Lab-grade RBAC so the provider can manage cluster objects
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: provider-kubernetes-admin
subjects:
  - kind: ServiceAccount
    name: provider-kubernetes
    namespace: crossplane-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
EOF

# In-cluster ProviderConfig
sleep 5
cat <<'EOF' | kubectl apply -f -
apiVersion: kubernetes.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: InjectedIdentity
EOF

# --- XRD (given) -----------------------------------------------------------------
cat <<'EOF' | kubectl apply -f -
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: xwebapps.platform.acme.dev
spec:
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
          properties:
            spec:
              type: object
              required: [appName, desiredReplicas, containerImage, targetNamespace]
              properties:
                appName:
                  type: string
                desiredReplicas:
                  type: integer
                containerImage:
                  type: string
                targetNamespace:
                  type: string
EOF

kubectl create namespace compose-sandbox --dry-run=client -o yaml | kubectl apply -f -

# --- The incomplete Composition the candidate must finish -------------------------
cat <<'EOF' > /root/composition.yaml
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  name: xwebapp-kubernetes
spec:
  compositeTypeRef:
    apiVersion: platform.acme.dev/v1alpha1
    kind: XWebApp
  mode: Resources
  resources:
    - name: app-deployment
      base:
        apiVersion: kubernetes.crossplane.io/v1alpha2
        kind: Object
        spec:
          providerConfigRef:
            name: default
          forProvider:
            manifest:
              apiVersion: apps/v1
              kind: Deployment
              metadata:
                name: placeholder
                namespace: placeholder
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
        # Example patch (already complete): XR targetNamespace -> Deployment namespace
        - type: FromCompositeFieldPath
          fromFieldPath: spec.targetNamespace
          toFieldPath: spec.forProvider.manifest.metadata.namespace
        # TODO(1): spec.appName        -> Deployment metadata.name
        # TODO(2): spec.appName        -> pod template label 'app'
        # TODO(3): spec.appName        -> selector matchLabels 'app'
        # TODO(4): spec.desiredReplicas -> Deployment replicas
        # TODO(5): spec.containerImage  -> first container image

    - name: app-service
      base:
        apiVersion: kubernetes.crossplane.io/v1alpha2
        kind: Object
        spec:
          providerConfigRef:
            name: default
          forProvider:
            manifest:
              apiVersion: v1
              kind: Service
              metadata:
                name: placeholder
                namespace: placeholder
              spec:
                selector:
                  app: placeholder
                ports:
                  - port: 80
                    targetPort: 80
      patches:
        - type: FromCompositeFieldPath
          fromFieldPath: spec.targetNamespace
          toFieldPath: spec.forProvider.manifest.metadata.namespace
        - type: FromCompositeFieldPath
          fromFieldPath: spec.appName
          toFieldPath: spec.forProvider.manifest.metadata.name
        - type: FromCompositeFieldPath
          fromFieldPath: spec.appName
          toFieldPath: spec.forProvider.manifest.spec.selector.app
EOF

# --- The XR to apply in step 2 ------------------------------------------------------
cat <<'EOF' > /root/app-xr.yaml
apiVersion: platform.acme.dev/v1alpha1
kind: XWebApp
metadata:
  name: demo-site
spec:
  appName: demo-site
  desiredReplicas: 2
  containerImage: nginx:1.25
  targetNamespace: compose-sandbox
EOF

touch /tmp/.cnpe-setup-done
