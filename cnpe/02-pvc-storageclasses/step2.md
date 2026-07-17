# Create the PVCs and unblock the apps

Create the two claims in `storage-lab`:

| Claim | Size | Access mode | StorageClass |
|---|---|---|---|
| `pg-storage` | 512Mi | ReadWriteOnce | the high-IOPS class |
| `cdn-cache` | 512Mi | ReadWriteOnce | the standard class |

Then confirm both Pods reach `Running`.

<details><summary>✦ Tip</summary>

Both classes use `volumeBindingMode: WaitForFirstConsumer` - the PVC will show
`Pending` until the Pod that uses it is scheduled. That is normal, not an error.
Since the Pods already exist, binding happens seconds after you create the claims.

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pg-storage
  namespace: storage-lab
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: fast-iops
  resources:
    requests:
      storage: 512Mi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cdn-cache
  namespace: storage-lab
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: standard
  resources:
    requests:
      storage: 512Mi
EOF
```{{exec}}

Watch everything come up:

```plain
kubectl -n storage-lab get pvc,pods
```{{exec}}

If a Pod is still stuck after the PVC binds, give the kubelet a few seconds or check:

```plain
kubectl -n storage-lab describe pod -l app=pg | tail -12
```{{exec}}

</details>
