# Alpha: things you can feel on a single Pod

Three small storage alphas from 1.37. Unlike the scheduling one, you can watch each of
these change behaviour inside a container in about ten seconds.

| Field | Gate |
| --- | --- |
| `emptyDir.mode` | `EmptyDirVolumeMode` |
| `volumeMounts[].bindMountOptions` | `VolumeBindMountOptions` |
| `configMap.defaultUser` / `items[].user` | `AtomicWriteVolumeUserFields` |

## Set it all up in one Pod

```plain
kubectl create configmap app-conf --from-literal=greeting=hello --dry-run=client -o yaml | kubectl apply -f -
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
      bindMountOptions: ["noexec", "nosuid", "nodev"]
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
kubectl wait --for=condition=Ready pod/volume-alpha --timeout=90s
```{{exec}}

A note on how gated fields fail: if `EmptyDirVolumeMode` or `VolumeBindMountOptions` were
off, this Pod would still be **accepted** - the apiserver silently strips fields behind a
disabled gate rather than erroring. You would only notice downstream, when `stat` reports
`777` and `/proc/mounts` shows no `noexec`. If that happens here, run
`/root/alpha/gate.sh show` and turn the gates on as shown in step 5.

## 1. `emptyDir.mode`

Before 1.37 an emptyDir was always `0777` and your only lever was `fsGroup`. Now you set the
bits directly:

```plain
kubectl exec volume-alpha -- stat -c '%a %n' /data/strict /data/normal
```{{exec}}

`700` on the one you asked for, `777` on the default. Values from `0000` to `01777` are
allowed, so `01777` gives you sticky-bit `/tmp` semantics.

## 2. `bindMountOptions`

`noexec`, `nodev` and `nosuid` are ordinary Linux mount options that were simply not
reachable from a Pod spec until now. Check what the kubelet actually mounted:

```plain
kubectl exec volume-alpha -- grep -E ' /data/(strict|normal) ' /proc/mounts
```{{exec}}

Now prove `noexec` bites. Copy a real binary onto each volume and try to run it:

```plain
kubectl exec volume-alpha -- sh -c 'cp /bin/busybox /data/normal/bb && /data/normal/bb echo "ran from normal volume"'
```{{exec}}

```plain
kubectl exec volume-alpha -- sh -c 'cp /bin/busybox /data/strict/bb && /data/strict/bb echo "should never print"'
```{{exec}}

The second one fails with **Permission denied** even though the file is `+x` and the process
is root. That is the kernel refusing to `execve` off a `noexec` mount - a genuinely useful
hardening knob for writable scratch space that attackers love to drop payloads into.

## 3. `defaultUser` on an atomically-written volume

ConfigMap, Secret, projected and ClusterTrustBundle volumes are written atomically by the
kubelet, and until 1.37 the files were always owned by root. Now you pick the owner UID:

```plain
kubectl exec volume-alpha -- stat -c '%u %a %n' /etc/app/greeting
```{{exec}}

`1000`, not `0`. Set it per file instead with `items[].user`, which overrides `defaultUser`.
This is the piece that lets a non-root container read a mounted Secret without granting
world-read on it.

## Clean up

```plain
kubectl delete pod volume-alpha --ignore-not-found && kubectl delete cm app-conf --ignore-not-found
```{{exec}}
