# Patch an XWebApp Composition in Crossplane

**Domain:** Platform APIs and Self-Service Capabilities &nbsp;|&nbsp; **Suggested time:** 14 minutes

Your platform offers app teams a one-object API: apply an **`XWebApp`**, get a running
Deployment + Service. The XRD exists, provider-kubernetes is healthy, and a colleague
left the Composition **half-finished** at **`/root/composition.yaml`**.

The Service side is done. The Deployment side has an example patch plus five TODOs - 
complete them so XR fields map into the composed Deployment:

| From XR field | To Deployment field |
|---|---|
| `spec.appName` | `metadata.name` |
| `spec.appName` | `spec.template.metadata.labels.app` |
| `spec.appName` | `spec.selector.matchLabels.app` |
| `spec.desiredReplicas` | `spec.replicas` |
| `spec.containerImage` | `spec.template.spec.containers[0].image` |

⚠️ The composed resource is a provider-kubernetes **Object** that wraps the Deployment,
so every `toFieldPath` starts with **`spec.forProvider.manifest.`** - the example patch
in the file shows the pattern.

Then apply **`/root/app-xr.yaml`** and confirm a Deployment **and** Service named
`demo-site` appear in **`compose-sandbox`**.

Click **START** while Crossplane installs.
