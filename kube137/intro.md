# Kubernetes 1.37 playground

A single node **Kubernetes 1.37** cluster with **containerd** as the runtime, built with
`kubeadm` and Flannel for pod networking.

Kubernetes 1.37 was released on **26 August 2026**
([release notes](https://github.com/kubernetes/kubernetes/releases/tag/v1.37.0)).

This is not just a plain playground: the cluster comes up with **a handful of 1.37 alpha
feature gates already switched on**, and the scenario walks you through how that is done and
what each one lets you do. By the end you will have hands-on with:

- **Gang scheduling** with the Workload / PodGroup API (`scheduling.k8s.io/v1beta1`)
- **`emptyDir.mode`** - custom permission bits on emptyDir volumes
- **`configMap.defaultUser`** - file ownership on atomically-written volumes
- **`volumeMounts[].bindMountOptions`** - and why 1.37 refuses to schedule it here
- **StatefulSet `Recreate`** update strategy
- Flipping any other feature gate yourself, and rolling it back

Sit back while the cluster builds - it takes a couple of minutes.
