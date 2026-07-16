# Fix them within the rules

All three fixes are **create/update of allowed objects** — the Deployments stay
untouched.

<details><summary>✅ Fix 1 — loosen the quota</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: portal-quota
  namespace: metrics-portal
spec:
  hard:
    pods: "4"
EOF
```{{exec}}

</details>

<details><summary>✅ Fix 2 — create the missing Secret</summary>

```bash
kubectl -n metrics-portal create secret generic metrics-db-auth \
  --from-literal=POSTGRES_PASSWORD='s3cret-p0rtal'
```{{exec}}

The kubelet retries container creation on its own — no Pod delete needed for
`CreateContainerConfigError` (deleting it is also fine and faster).

</details>

<details><summary>✅ Fix 3 — create the missing PVC</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: metrics-ui-data
  namespace: metrics-portal
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 256Mi
EOF
```{{exec}}

(No `storageClassName` = the cluster default class. Fine here.)

</details>

Now watch it heal — the ReplicaSet retries pod creation with backoff, so the
`metrics-ui` pod can take a minute to appear after the quota fix:

```plain
kubectl -n metrics-portal get pods -w
```{{exec interrupt}}

Both Deployments must reach Available:

```bash
kubectl -n metrics-portal wait --for=condition=available deploy --all --timeout=300s
kubectl -n metrics-portal get deploy,pods,pvc
```{{exec}}

<details><summary>✦ Impatient? Legal shortcuts</summary>

- Delete the `CreateContainerConfigError` pod → recreated instantly, picks up the Secret
- The quota-blocked pod cannot be hurried by deleting (nothing exists yet) — the RS
  controller retries within ~1 minute. Breathe.

</details>
