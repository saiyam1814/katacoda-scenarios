# That's Kubernetes 1.37 🎉

You ran a 1.37 cluster and drove four alpha/beta features end to end:

- **Gang scheduling** - `GenericWorkload` + `scheduling.k8s.io/v1beta1`, all-or-nothing
  placement via `PodGroup` and `spec.schedulingGroup.podGroupName`
- **`emptyDir.mode`** - permission bits on scratch volumes without `fsGroup` gymnastics
- **`bindMountOptions`** - blocked by `NodeDeclaredFeatures` because containerd does not
  advertise `MountOptions`, which is the more useful lesson: an alpha feature can depend on
  your container runtime, and 1.37 tells you so instead of ignoring the field
- **`defaultUser`** - file ownership on ConfigMap, Secret and projected volumes
- **StatefulSet `Recreate`** - tear the whole set down before bringing the new version up

And the rules that make any alpha feature work:

1. `--feature-gates=Gate=true` on **every** component that participates, kubelet included
2. `--runtime-config=group/version=true` on kube-apiserver if it ships new types
3. Gates now have **dependencies** - miss one and the component refuses to start
4. Some features also need the node (or its runtime) to declare support

## Where to go next

- [v1.37.0 release notes](https://github.com/kubernetes/kubernetes/releases/tag/v1.37.0)
- [CHANGELOG-1.37.md](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.37.md)
- [Feature gates reference](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/)

Other alphas in 1.37 worth a look, all flippable with `/root/alpha/gate.sh`:
`EvictionRequestAPI`, `H2CContainerProbe`, `GRPCContainerProbeTLS`, `DefaultPodSysctls`,
`VolumeBindMountOptions`, `InPlacePodVerticalScalingMemoryBackedVolumes`,
`KubeletAllocatedPodsEndpoint`, `InterPodAffinityHostnameFastPath`,
and the DRA family (`DRADeviceCompatibilityGroups`, `DRAOptionalNodeOperations`,
`DRAPartitionableDevicesType`, `DRADerivedAttributes`).

Before you upgrade a real cluster to 1.37, read the **Urgent Upgrade Notes**: `SELinuxMount`
going GA can break SELinux workloads, `scheduling.k8s.io/v1alpha2` objects must be removed
first, and `eventRecordQPS: 0` now means unlimited.
