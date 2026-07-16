# Create the guardrails

Create both objects in the `squad-nebula` namespace:

1. ResourceQuota **`nebula-pod-cap`** — hard cap of **6 Pods**
2. LimitRange **`nebula-cpu-defaults`** — per **Container**:
   - `defaultRequest` CPU `50m`
   - `default` (limit) CPU `50m`
   - `max` CPU `250m`

Have a look at what already runs there first:

```plain
kubectl -n squad-nebula get deploy,pods
```{{exec}}

<details><summary>✦ Tip 1</summary>

`kubectl create quota --help` can generate a quota fast:

```plain
kubectl create quota nebula-pod-cap --hard=pods=6 -n squad-nebula
```{{exec}}

There is no generator for LimitRange — write YAML.
`kubectl explain limitrange.spec.limits` shows every field.

</details>

<details><summary>✦ Tip 2</summary>

In a LimitRange item of `type: Container`:

- `defaultRequest` → filled into `resources.requests` when missing
- `default` → filled into `resources.limits` when missing
- `max` → hard ceiling, admission rejects anything above it

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: nebula-pod-cap
  namespace: squad-nebula
spec:
  hard:
    pods: "6"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: nebula-cpu-defaults
  namespace: squad-nebula
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 50m
      default:
        cpu: 50m
      max:
        cpu: 250m
EOF
```{{exec}}

Check them:

```plain
kubectl -n squad-nebula describe quota,limitrange
```{{exec}}

</details>
