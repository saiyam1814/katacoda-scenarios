# Create the Constraint

Inspect the template first - its `crd.spec.names.kind` is the kind **you** must
instantiate:

```bash
kubectl get constrainttemplate forbidfloatingtag \
  -o jsonpath='{.spec.crd.spec.names.kind}' ; echo
```{{exec}}

Now write the Constraint. The `match.kinds` list uses **apiGroups + kinds** pairs.

<details><summary>✦ Tip</summary>

Constraints use the API group `constraints.gatekeeper.sh/v1beta1`, and the **kind** is
whatever the template declared - here `ForbidFloatingTag`. Core-group resources (Pod)
use `apiGroups: [""]`.

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: ForbidFloatingTag
metadata:
  name: forbid-floating-tags
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment", "DaemonSet", "StatefulSet", "ReplicaSet"]
      - apiGroups: ["batch"]
        kinds: ["Job", "CronJob"]
      - apiGroups: [""]
        kinds: ["Pod"]
EOF
```{{exec}}

```plain
kubectl get forbidfloatingtag forbid-floating-tags
```{{exec}}

Give the webhook a few seconds to sync before testing.

</details>
