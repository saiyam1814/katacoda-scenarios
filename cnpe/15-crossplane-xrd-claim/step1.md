# Create the XRD with claim names

The XRD is like a CRD plus two Crossplane extras: **`claimNames`** (enables the
namespaced proxy object) and **`referenceable`** (lets Compositions target it).

<details><summary>✦ Tip — XRD skeleton</summary>

```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: <plural>.<group>       # must match names below
spec:
  group: <group>
  names:                        # the composite (cluster-scoped)
    kind: XSomething
    plural: xsomethings
  claimNames:                   # the claim (namespaced)
    kind: Something
    plural: somethings
  versions: [...]
```{{copy}}

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: xbucketapps.platform.example.io
spec:
  group: platform.example.io
  names:
    kind: XBucketApp
    plural: xbucketapps
  claimNames:
    kind: BucketApp
    plural: bucketapps
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
              required: [region, size]
              properties:
                region:
                  type: string
                size:
                  type: string
EOF
```{{exec}}

Watch it become Established and Offered (Offered = claims are available):

```bash
kubectl get xrd xbucketapps.platform.example.io
kubectl api-resources --api-group=platform.example.io
```{{exec}}

</details>
