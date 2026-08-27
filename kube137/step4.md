# Alpha: emptyDir mode, file ownership, and a lesson in node features

Two 1.37 storage alphas you can feel inside a container in ten seconds, and a third that
teaches you something more useful than it would have if it just worked.

| Field | Gate | Works here? |
| --- | --- | --- |
| `emptyDir.mode` | `EmptyDirVolumeMode` | yes |
| `configMap.defaultUser` / `items[].user` | `AtomicWriteVolumeUserFields` | yes |
| `volumeMounts[].bindMountOptions` | `VolumeBindMountOptions` | needs runtime support - see below |

## Set up

```plain
kubectl create configmap app-conf --from-literal=greeting=hello
```{{exec}}

```plain
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: volume-alpha
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: strict
      mountPath: /data/strict
    - name: normal
      mountPath: /data/normal
    - name: conf
      mountPath: /etc/app
  volumes:
  - name: strict
    emptyDir:
      mode: 0700
  - name: normal
    emptyDir: {}
  - name: conf
    configMap:
      name: app-conf
      defaultUser: 1000
EOF
```{{exec}}

```plain
kubectl wait --for=condition=Ready pod/volume-alpha --timeout=120s
```{{exec}}

## 1. `emptyDir.mode`

Before 1.37 an emptyDir was always `0777` and your only lever was `fsGroup`. Now you set the
bits directly:

```plain
kubectl exec volume-alpha -- stat -c '%a %n' /data/strict /data/normal
```{{exec}}

```plain
700 /data/strict
777 /data/normal
```

`700` on the one you asked for, `777` on the default. Values from `0000` to `01777` are
allowed, so `01777` gives you sticky-bit `/tmp` semantics.

## 2. `defaultUser` on an atomically-written volume

ConfigMap, Secret, projected and ClusterTrustBundle volumes are written atomically by the
kubelet, and until 1.37 those files were always owned by root. Now you pick the owner UID:

```plain
kubectl exec volume-alpha -- stat -c '%u %a %n' /etc/app/greeting
```{{exec}}

```plain
1000 777 /etc/app/greeting
```

UID `1000`, not `0`. Set it per file instead with `items[].user`, which overrides
`defaultUser`. This is what lets a non-root container read a mounted Secret without granting
world-read on it.

## 3. `bindMountOptions`, and why it does not work here

`noexec`, `nodev` and `nosuid` are ordinary Linux mount options that were not reachable from
a Pod spec until now. Add one to the same Pod:

```plain
kubectl delete pod volume-alpha --force --grace-period=0
```{{exec}}

```plain
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: volume-strict
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: strict
      mountPath: /data/strict
      bindMountOptions: ["noexec", "nosuid", "nodev"]
  volumes:
  - name: strict
    emptyDir: {}
EOF
```{{exec}}

The apiserver accepts it. But the Pod never starts:

```plain
kubectl get pod volume-strict
```{{exec}}

```plain
kubectl describe pod volume-strict | tail -4
```{{exec}}

```plain
Warning  FailedScheduling  ...  0/1 nodes are available:
1 node(s) didn't match Pod's required features.
```

**This is `NodeDeclaredFeatures`, which went GA in 1.37, doing its job.** The kubelet
publishes what the node can actually honour, and the scheduler refuses to place a Pod that
needs something missing. Look at what this node declares:

```plain
kubectl get node -o jsonpath='{.items[0].status.declaredFeatures}'; echo
```{{exec}}

`VolumeBindMountOptions` is not in that list, even though the gate is on everywhere. The
feature needs two things, not one:

```go
Discover: cfg.FeatureGates.Enabled("VolumeBindMountOptions") && cfg.RuntimeFeatures.MountOptions
```

The second half is a **CRI runtime capability**, and the containerd on this box does not
advertise `MountOptions`:

```plain
containerd --version
```{{exec}}

So the honest lesson is the one worth more than a working `noexec` demo: in 1.37 an alpha
feature can be gated on your *container runtime*, not just your control plane, and the
failure now surfaces as a clear scheduling event instead of a silently ignored field. Before
1.37 this Pod would have started and quietly mounted without `noexec`.

## Clean up

```plain
kubectl delete pod volume-strict --force --grace-period=0 --ignore-not-found
kubectl delete cm app-conf --ignore-not-found
```{{exec}}
