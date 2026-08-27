# Posts

Scenario link to use everywhere: **https://killercoda.com/saiyampathak/scenario/kube137**

---

## LinkedIn

> Kubernetes 1.37 is out, so I built a free hands-on playground for it. No install, no cloud
> account, runs in your browser.
>
> Most release write-ups list what changed. I wanted to actually turn the alpha features on and
> run them, because the most interesting thing about 1.37 is not any single feature. It is that
> enabling alpha features got harder, and that is a good thing.
>
> Three things I learned the hard way while building it:
>
> 𝗙𝗲𝗮𝘁𝘂𝗿𝗲 𝗴𝗮𝘁𝗲𝘀 𝗻𝗼𝘄 𝗵𝗮𝘃𝗲 𝗱𝗲𝗽𝗲𝗻𝗱𝗲𝗻𝗰𝗶𝗲𝘀.
> I enabled CompositePodGroup, and kube-apiserver refused to boot:
> "enabled, but depends on features that are disabled: [TopologyAwareWorkloadScheduling]".
> A loud failure at startup beats a feature that half works.
>
> 𝗡𝗼𝗱𝗲𝘀 𝗻𝗼𝘄 𝗱𝗲𝗰𝗹𝗮𝗿𝗲 𝘄𝗵𝗮𝘁 𝘁𝗵𝗲𝘆 𝗰𝗮𝗻 𝗮𝗰𝘁𝘂𝗮𝗹𝗹𝘆 𝗱𝗼.
> NodeDeclaredFeatures went GA. I set bindMountOptions (noexec on a volume mount), the
> apiserver accepted it, and the Pod never scheduled: "node(s) didn't match Pod's required
> features". It needs a CRI runtime advertising MountOptions, and containerd 2.2.1 does not.
> Before 1.37 that Pod would have started and quietly mounted without noexec. You would have
> shipped it thinking your scratch dir was hardened.
>
> 𝗚𝗮𝗻𝗴 𝘀𝗰𝗵𝗲𝗱𝘂𝗹𝗶𝗻𝗴 𝗶𝘀 𝗿𝗲𝗮𝗹.
> Workload and PodGroup moved to scheduling.k8s.io/v1beta1. Three replicas that cannot all fit:
> without a PodGroup you get 1 Running and 2 Pending, one Pod burning a slot for a job that can
> never start. With gang.minCount: 3 you get 0 Running and 3 Pending. All or nothing.
>
> The scenario boots a 1.37 cluster with nine gates already on and walks through each one, plus
> a helper script for flipping any other gate and rolling it back when you break something.
>
> Free, browser-based: https://killercoda.com/saiyampathak/scenario/kube137
>
> #Kubernetes #CloudNative #K8s #Platform Engineering #DevOps

---

## X - single post

> Kubernetes 1.37 is out. I built a free browser playground that boots a 1.37 cluster with 9
> alpha gates already on.
>
> Best thing I learned: gates now have dependencies. Enable CompositePodGroup without
> TopologyAwareWorkloadScheduling and kube-apiserver just refuses to start.
>
> https://killercoda.com/saiyampathak/scenario/kube137

---

## X - thread (6 posts)

**1/**
> Kubernetes 1.37 dropped. I didn't want to just read the changelog, so I built a free
> browser-based playground that boots a 1.37 cluster with 9 alpha feature gates already
> switched on.
>
> Three things I learned by actually running them 🧵

**2/**
> Feature gates now have dependencies, and the check is fatal.
>
> I enabled CompositePodGroup. kube-apiserver refused to boot:
>
> "enabled, but depends on features that are disabled: [TopologyAwareWorkloadScheduling]"
>
> Loud failure at startup > a feature that half works.

**3/**
> Gang scheduling is real. Workload + PodGroup are now scheduling.k8s.io/v1beta1.
>
> 3 replicas that can't all fit:
>
> no PodGroup  -> 1 Running, 2 Pending
> gang minCount:3 -> 0 Running, 3 Pending
>
> All or nothing. No Pod burning a slot for a job that can never start.

**4/**
> NodeDeclaredFeatures went GA and it caught me.
>
> I set bindMountOptions (noexec on a mount). Apiserver accepted it. Pod never scheduled:
>
> "node(s) didn't match Pod's required features"
>
> It needs a CRI runtime advertising MountOptions. containerd 2.2.1 doesn't.

**5/**
> That failure is the upgrade.
>
> Before 1.37 that Pod would have started, mounted without noexec, and told you nothing. You
> ship it thinking your scratch dir is hardened.
>
> Now the scheduler names the problem.

**6/**
> Also stable in 1.37: kubectl get -o kyaml. Every string quoted, so `no` stays "no" and 1.10
> stays "1.10". Small, but you'll use it daily.
>
> Full hands-on, free, no signup:
> https://killercoda.com/saiyampathak/scenario/kube137

---

## Short blog post

### I turned on nine alpha features in Kubernetes 1.37 so you don't have to

Kubernetes 1.37 landed on 26 August 2026. I built a
[free browser-based playground](https://killercoda.com/saiyampathak/scenario/kube137) for it,
and rather than list the changelog, I tried to actually enable and run the alpha features.
That turned out to be the interesting part.

**Enabling an alpha feature is not one switch.** It is at least two, and in 1.37 sometimes
four. The gate goes on every component that participates, including the kubelet. If the
feature ships new API types you also need `--runtime-config=group/version=true` on the
apiserver, or `kubectl apply` will tell you `no matches for kind` with the gate happily
enabled. One note that catches people with kubeadm: the gates go in each component's
`extraArgs`, not in `ClusterConfiguration.featureGates`, which is for kubeadm's own gates.

**Gates now declare dependencies on other gates, and the check is fatal.** I enabled
`CompositePodGroup` and my apiserver refused to boot:

```
command failed ... enabled, but depends on features that are disabled:
[TopologyAwareWorkloadScheduling]
```

That is the right behaviour. A component that refuses to start beats a feature that silently
half works.

**Gang scheduling is the headline.** `Workload` and `PodGroup` were promoted to
`scheduling.k8s.io/v1beta1`, and the old `GangScheduling` and `WorkloadAwarePreemption` gates
were collapsed into one gate, `GenericWorkload`. The problem it solves is familiar to anyone
running training jobs: three workers, two get scheduled, one does not, and those two now sit on
hardware doing nothing while blocking everyone else. In the scenario, three replicas that
cannot all fit give you `1 Running, 2 Pending` normally, and `0 Running, 3 Pending` once they
belong to a PodGroup with `gang.minCount: 3`. Pods join a group through a new Pod spec field,
`spec.schedulingGroup.podGroupName`.

**Nodes now declare what they can actually do.** `NodeDeclaredFeatures` went GA. I set
`bindMountOptions: ["noexec"]` on a volume mount, the apiserver accepted it, and the Pod never
scheduled:

```
0/1 nodes are available: 1 node(s) didn't match Pod's required features.
```

The gate was on everywhere. The feature also requires a CRI runtime that advertises
`MountOptions`, and containerd 2.2.1 does not. So it cannot work on this box, and 1.37 tells
you that up front. Before this release, the Pod would have started, mounted without `noexec`,
and said nothing at all. You would have shipped it believing your writable scratch directory
was hardened. I left the broken example in the scenario on purpose, because that failure
teaches more than a working demo would have.

A few smaller things worth knowing: `kubectl get -o kyaml` is stable, and it quotes every
string so `no` stays a string and `1.10` stays a version. StatefulSets finally get a `Recreate`
update strategy in alpha, though `kubectl rollout status` does not support it yet. The default
etcd version moved to 3.7.0. And if you run SELinux, read the upgrade notes before you touch
1.37: `SELinuxMount` going GA can break existing workloads.

The scenario is free and runs in the browser with no signup. It boots the cluster with the
gates already on, and ships a small helper for flipping any other gate and rolling it back
when you break something, which you will.

[Try it](https://killercoda.com/saiyampathak/scenario/kube137)
