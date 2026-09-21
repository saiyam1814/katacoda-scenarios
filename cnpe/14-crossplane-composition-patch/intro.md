# Complete a Crossplane v2 Composition

Crossplane v2 and function-patch-and-transform are installed. The namespaced
`XWebApp` API already exists. Complete `/root/composition.yaml` so the
`app-deployment` resource maps these XR fields:

| From | To |
|---|---|
| `spec.appName` | `metadata.name` |
| `spec.appName` | `spec.template.metadata.labels.app` |
| `spec.appName` | `spec.selector.matchLabels.app` |
| `spec.desiredReplicas` | `spec.replicas` |
| `spec.containerImage` | `spec.template.spec.containers[0].image` |

Keep the existing namespace patch and Service resource. Apply the Composition and
`/root/app-xr.yaml`. The XR `demo-site` in `compose-sandbox` must create a Deployment
with two `nginx:1.25` replicas and a Service selecting its Pods. Do not create or
edit the Deployment and Service manually.
