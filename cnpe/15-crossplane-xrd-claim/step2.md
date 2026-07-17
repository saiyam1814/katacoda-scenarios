# Compose it and claim a bucket

Apply the platform-side Composition (this one is given - you built one from scratch in
lab 14):

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  name: xbucketapp-objects
spec:
  compositeTypeRef:
    apiVersion: platform.example.io/v1alpha1
    kind: XBucketApp
  mode: Resources
  resources:
    - name: bucket
      base:
        apiVersion: kubernetes.crossplane.io/v1alpha2
        kind: Object
        spec:
          providerConfigRef:
            name: default
          forProvider:
            manifest:
              apiVersion: v1
              kind: ConfigMap
              metadata:
                name: placeholder
                namespace: bucket-system
                labels:
                  platform.example.io/kind: bucket
              data:
                region: placeholder
                size: placeholder
      patches:
        - type: FromCompositeFieldPath
          fromFieldPath: metadata.name
          toFieldPath: spec.forProvider.manifest.metadata.name
        - type: FromCompositeFieldPath
          fromFieldPath: spec.region
          toFieldPath: spec.forProvider.manifest.data.region
        - type: FromCompositeFieldPath
          fromFieldPath: spec.size
          toFieldPath: spec.forProvider.manifest.data.size
EOF
```{{exec}}

Now switch hats: you are an app developer in `team-apps`. Claim a bucket:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: platform.example.io/v1alpha1
kind: BucketApp
metadata:
  name: media-assets
  namespace: team-apps
spec:
  region: eu-west-1
  size: small
EOF
```{{exec}}

Wait for readiness and trace the chain - Claim → XR → Object → ConfigMap:

```bash
kubectl -n team-apps wait bucketapp/media-assets --for=condition=Ready --timeout=180s
kubectl -n team-apps get bucketapp
kubectl get xbucketapp
kubectl -n bucket-system get cm -l platform.example.io/kind=bucket -o yaml | grep -E "name:|region|size" | head -6
```{{exec}}

<details><summary>✦ Note - claim vs XR names</summary>

The claim is `media-assets` in `team-apps`; Crossplane generated a cluster-scoped XR
named `media-assets-<hash>` for it. That XR name flowed into the ConfigMap name via
the `metadata.name` patch. Claims are the **only** namespaced piece - that is what
makes them safe to hand to tenants (RBAC on the claim kind per namespace).

</details>
