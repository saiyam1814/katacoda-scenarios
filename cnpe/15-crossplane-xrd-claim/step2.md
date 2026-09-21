# Compose a ConfigMap from the XR

Read the supplied Composition. It uses a Pipeline function to map `spec.region`
and `spec.size` to native ConfigMap data in the XR's namespace.

```bash
kubectl apply -f /root/bucket-composition.yaml
```{{exec}}

<details><summary>Solution: composite resource</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: platform.example.io/v1alpha1
kind: BucketApp
metadata:
  name: media-assets
  namespace: team-apps
spec:
  crossplane:
    compositionRef:
      name: bucketapp-configmap
  region: eu-west-1
  size: small
EOF
kubectl -n team-apps wait bucketapp/media-assets --for=condition=Ready --timeout=180s
kubectl -n team-apps get bucketapp media-assets
kubectl -n team-apps get configmap media-assets -o yaml
```{{exec}}

The ConfigMap must contain `region: eu-west-1` and `size: small` and have an owner
reference to the XR. Its readiness check is `None` because ConfigMaps have no Ready
condition; this does not prove that any cloud bucket exists.
</details>
