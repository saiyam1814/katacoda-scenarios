# Complete the Composition patches

Confirm the machinery is healthy, then open the file:

```plain
kubectl get providers
kubectl get xrd
vim /root/composition.yaml
```{{copy}}

Replace the five `TODO` comments with real patches. Follow the example patch above
them — same `type`, different paths.

<details><summary>✦ Tip — patch anatomy</summary>

```yaml
- type: FromCompositeFieldPath     # read from the XR ...
  fromFieldPath: spec.appName      # ... this field
  toFieldPath: spec.forProvider.manifest.metadata.name   # write it here
```{{copy}}

Array elements use `[0]` syntax: `...containers[0].image`.
`FromCompositeFieldPath` is also the **default** type, but writing it out keeps
the intent obvious.

</details>

<details><summary>✅ Solution — the five patches</summary>

Add these under the `app-deployment` resource's `patches:` (after the example):

```yaml
        - type: FromCompositeFieldPath
          fromFieldPath: spec.appName
          toFieldPath: spec.forProvider.manifest.metadata.name
        - type: FromCompositeFieldPath
          fromFieldPath: spec.appName
          toFieldPath: spec.forProvider.manifest.spec.template.metadata.labels.app
        - type: FromCompositeFieldPath
          fromFieldPath: spec.appName
          toFieldPath: spec.forProvider.manifest.spec.selector.matchLabels.app
        - type: FromCompositeFieldPath
          fromFieldPath: spec.desiredReplicas
          toFieldPath: spec.forProvider.manifest.spec.replicas
        - type: FromCompositeFieldPath
          fromFieldPath: spec.containerImage
          toFieldPath: spec.forProvider.manifest.spec.template.spec.containers[0].image
```{{copy}}

Then apply it:

```bash
kubectl apply -f /root/composition.yaml
```{{exec}}

</details>
