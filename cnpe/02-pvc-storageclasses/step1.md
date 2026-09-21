# Investigate the stuck Pods

Before writing YAML, understand *why* the Pods are stuck and *what exactly* they expect.
Inspect the existing cluster resources for the required names.

Look at the Pods:

```plain
kubectl -n storage-lab get pods
```{{exec}}

Find out which claim each Deployment references:

```plain
kubectl -n storage-lab get deploy -o yaml | grep -B2 -A3 claimName
```{{exec}}

And which StorageClasses the cluster offers:

```plain
kubectl get storageclass
```{{exec}}

Create a marker file once you know the two claim names and the two class names
(these marker files are specific to the practice lab):

```bash
touch /root/investigated
```{{exec}}

<details><summary>✦ What you should have found</summary>

- Pod `pg-…` is `Pending` - claim `pg-storage` does not exist
- Pod `cdn-…` is `Pending` - claim `cdn-cache` does not exist
- Classes available: `fast-iops` (annotated `high-iops` tier), `standard`, and the
  cluster default `local-path`

`kubectl describe pod <name> -n storage-lab` shows the event:
`persistentvolumeclaim "pg-storage" not found`.

</details>
