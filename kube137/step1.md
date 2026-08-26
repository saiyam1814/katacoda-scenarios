# Wait for the cluster, then look around

The setup script is installing containerd, the 1.37 binaries, and running `kubeadm init`.
Keep running this until the node reports `Ready`:

```plain
kubectl get nodes
```{{exec}}

Confirm you really are on 1.37:

```plain
kubectl version
```{{exec}}

## A few things that changed in 1.37

**Graduated to GA / stable**

- `kubectl get -o kyaml` is now **stable** - a YAML dialect that always quotes ambiguous
  scalars, so `yes`, `no` and `1.10` stop biting you.
- Pod **hostname overrides** (`spec.hostnameOverride`) - gate locked on.
- `PodReadyToStartContainers` condition, `InPlacePodVerticalScalingInitContainers`,
  `NodeDeclaredFeatures`, `HPAConfigurableTolerance`, `ClusterTrustBundle` +
  `ClusterTrustBundleProjection`, `DRAResourceClaimDeviceStatus`, `PLEGOnDemandRelist`,
  and `RelaxedServiceNameValidation` all went GA.
- `SELinuxMount` went GA - **read the release notes before upgrading a real cluster with
  SELinux**, it can break existing workloads.

**On by default now**

- `PodLevelResourceManagers` and `MaxUnavailableStatefulSet` are enabled by default.
- `WatchListCompression` (gzip for watch-list responses) and `EtcdRangeStream` went beta-on.
- Default etcd version moved to **v3.7.0**.

Try the new stable output format:

```plain
kubectl get node -o kyaml | head -30
```{{exec}}

Compare it against plain YAML - notice how kyaml quotes every string and uses flow style
for short lists:

```plain
kubectl get svc kubernetes -o kyaml
```{{exec}}

**Heads up on kube-proxy:** 1.37 warns when `KubeProxyConfiguration.mode` is not set
explicitly, because the default is moving to `nftables` in a future release. This scenario
pins `mode: iptables`, and `ipvs` mode is deprecated as of 1.35.

Now on to the interesting part - the alpha features.
