#!/bin/bash
exec >>/var/log/cnpe-setup.log 2>&1
set -x

export KUBECONFIG=/root/.kube/config
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

CROSSPLANE_CHART_VERSION=1.20.0
PROVIDER_K8S_VERSION=v0.18.0

helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update crossplane-stable
helm upgrade --install crossplane crossplane-stable/crossplane \
  --namespace crossplane-system --create-namespace \
  --version ${CROSSPLANE_CHART_VERSION} --wait --timeout 10m

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

# Namespaces: where claims are made, and where "buckets" land
kubectl create namespace team-apps --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace bucket-system --dry-run=client -o yaml | kubectl apply -f -

touch /tmp/.cnpe-setup-done
