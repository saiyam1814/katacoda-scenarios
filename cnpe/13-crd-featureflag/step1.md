# Create the CRD

The naming rules trip people up, so anchor them first:

- CRD **name** = `<plural>.<group>` → `featureflags.toggle.acme.dev`
- `spec.names`: `kind` (PascalCase), `plural`, `singular`, `shortNames`
- Validation lives in `versions[].schema.openAPIV3Schema`

<details><summary>✦ Tip - integer bounds</summary>

OpenAPI v3 integers support `minimum` / `maximum` directly:

```yaml
rolloutPercent:
  type: integer
  minimum: 0
  maximum: 100
```{{copy}}

And required fields are listed at the **object level**, not on each property.

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: featureflags.toggle.acme.dev
spec:
  group: toggle.acme.dev
  names:
    kind: FeatureFlag
    listKind: FeatureFlagList
    plural: featureflags
    singular: featureflag
    shortNames: [ff]
  scope: Namespaced
  versions:
    - name: v1beta1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          required: [spec]
          properties:
            spec:
              type: object
              required: [key, enabled, rolloutPercent]
              properties:
                key:
                  type: string
                enabled:
                  type: boolean
                rolloutPercent:
                  type: integer
                  minimum: 0
                  maximum: 100
EOF
```{{exec}}

Wait for the API server to establish it:

```bash
kubectl wait --for=condition=established crd/featureflags.toggle.acme.dev --timeout=30s
```{{exec}}

</details>

Use PascalCase for `kind` (`FeatureFlag`) and lowercase names for the plural and
short name. Modern kubectl uses strict field validation by default, so an unknown
field can cause rejection. If validation is set to warn or ignore, the API server
can prune fields not allowed by the structural schema. Required fields and bounds
are separate schema checks.
