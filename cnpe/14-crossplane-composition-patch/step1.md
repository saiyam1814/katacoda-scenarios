# Complete the function input

Inspect `kubectl get functions` and `kubectl get xrd`. The Composition remains
`apiextensions.crossplane.io/v1`; its `spec.mode` is `Pipeline`. Resource templates
live under `spec.pipeline[0].input.resources`, not `spec.resources`.

The base is a native Deployment, so patch its fields directly. The namespace patch
is already present. Add the following five entries to its `patches` list.

<details><summary>Solution: Deployment patches</summary>

```yaml
- type: FromCompositeFieldPath
  fromFieldPath: spec.appName
  toFieldPath: metadata.name
  policy:
    fromFieldPath: Required
- type: FromCompositeFieldPath
  fromFieldPath: spec.appName
  toFieldPath: spec.template.metadata.labels.app
  policy:
    fromFieldPath: Required
- type: FromCompositeFieldPath
  fromFieldPath: spec.appName
  toFieldPath: spec.selector.matchLabels.app
  policy:
    fromFieldPath: Required
- type: FromCompositeFieldPath
  fromFieldPath: spec.desiredReplicas
  toFieldPath: spec.replicas
  policy:
    fromFieldPath: Required
- type: FromCompositeFieldPath
  fromFieldPath: spec.containerImage
  toFieldPath: spec.template.spec.containers[0].image
  policy:
    fromFieldPath: Required
```{{copy}}

```bash
kubectl apply -f /root/composition.yaml
```{{exec}}

</details>
