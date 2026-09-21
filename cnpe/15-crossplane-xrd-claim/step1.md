# Define the namespaced composite resource

The v2 XRD creates a namespaced `BucketApp` API directly. There is no separate claim.
The XRD is cluster-scoped; the resources created through its API are namespaced.

<details><summary>Solution: XRD</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: apiextensions.crossplane.io/v2
kind: CompositeResourceDefinition
metadata:
  name: bucketapps.platform.example.io
spec:
  scope: Namespaced
  group: platform.example.io
  names:
    kind: BucketApp
    plural: bucketapps
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
            - region
            - size
            properties:
              region:
                type: string
              size:
                type: string
EOF
kubectl wait xrd/bucketapps.platform.example.io --for=condition=Established --timeout=120s
kubectl api-resources --api-group=platform.example.io
```{{exec}}

Expect `BucketApp` to report `NAMESPACED=true`. Wait for `Established`, not the
legacy `Offered` condition used for claim APIs.
</details>
