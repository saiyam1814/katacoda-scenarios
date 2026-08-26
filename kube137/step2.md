# How you actually turn alpha features on

Every alpha feature in Kubernetes sits behind a **feature gate**, and most of them are
`false` by default. Turning one on takes two things:

1. **The gate** - `--feature-gates=SomeGate=true` on every component that participates
   (usually kube-apiserver + kube-scheduler + kube-controller-manager + kubelet).
2. **The API group**, if the feature ships new types - `--runtime-config=group/version=true`
   on kube-apiserver. Alpha groups are *always* off by default, and since 1.24 new **beta**
   groups are off by default too.

Miss step 2 and `kubectl apply` just says `no matches for kind`, even with the gate on.

**New in 1.37: gates have dependencies.** Some gates now declare that they require other
gates, and the check is fatal - the component refuses to start rather than silently
misbehaving. Enable `CompositePodGroup` without `TopologyAwareWorkloadScheduling` and
kube-apiserver dies on boot with:

```plain
command failed ... enabled, but depends on features that are disabled:
[TopologyAwareWorkloadScheduling]
```

Worth knowing before you go gate-hunting: if the control plane will not come up after you
flip something, this is the first thing to check. `CompositePodGroup` needs
`GenericWorkload` **and** `TopologyAwareWorkloadScheduling`; `H2CContainerProbe` needs
`NodeDeclaredFeatures` (GA in 1.37, so already on).

## What this cluster was built with

The `kubeadm` config used at init time:

```plain
cat /root/alpha/kubeadm-alpha.yaml
```{{exec}}

Note that the gates go in each component's `extraArgs`, **not** in
`ClusterConfiguration.featureGates` - that field is for *kubeadm's own* gates, not the
Kubernetes ones. A common trip-up.

See what landed in the static pod manifests:

```plain
/root/alpha/gate.sh show
```{{exec}}

## Verify from the API side

The Workload and PodGroup types only appear when `GenericWorkload=true` **and**
`scheduling.k8s.io/v1beta1` is served:

```plain
kubectl api-resources --api-group=scheduling.k8s.io
```{{exec}}

You should see `workloads`, `podgroups` (v1beta1) and `compositepodgroups` (v1alpha3)
alongside `priorityclasses`. Confirm the group versions are actually being served:

```plain
kubectl get --raw /apis/scheduling.k8s.io | python3 -m json.tool
```{{exec}}

Ask the kubelet which gates *it* got:

```plain
kubectl get --raw "/api/v1/nodes/$(hostname -s)/proxy/configz" | python3 -m json.tool | grep -A 8 featureGates
```{{exec}}

## The gates on in this playground

| Gate | Stage in 1.37 | What it unlocks |
| --- | --- | --- |
| `GenericWorkload` | Beta (off by default) | Workload / PodGroup API + gang scheduling |
| `TopologyAwareWorkloadScheduling` | Alpha | `schedulingConstraints` on a PodGroup; required by `CompositePodGroup` |
| `CompositePodGroup` | Alpha | `CompositePodGroup` in `scheduling.k8s.io/v1alpha3` |
| `PodGroupPreemptionPolicy` | Alpha | `preemptionPolicy` on a PodGroup |
| `EmptyDirVolumeMode` | Alpha | `emptyDir.mode` permission bits |
| `VolumeBindMountOptions` | Alpha | `noexec` / `nodev` / `nosuid` on a volumeMount |
| `StatefulSetRecreateStrategy` | Alpha | StatefulSet `Recreate` update strategy |
| `AtomicWriteVolumeUserFields` | Alpha | file owner UID on projected/ConfigMap/Secret volumes |
| `H2CContainerProbe` | Alpha | `protocol` on an `httpGet` probe |

A helper is on the box for flipping others yourself - you will use it in step 5:

```plain
/root/alpha/gate.sh
```{{exec}}
