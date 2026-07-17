# Enable warn=baseline on the fleet

Pod Security Admission is configured with **namespace labels** - no policy engine
needed, it is built into the API server:

- `pod-security.kubernetes.io/warn=baseline`
- `pod-security.kubernetes.io/warn-version=latest`

Label all four fleet namespaces.

<details><summary>✅ Solution</summary>

```bash
for ns in fleet-1 fleet-2 fleet-3 fleet-4; do
  kubectl label ns "$ns" \
    pod-security.kubernetes.io/warn=baseline \
    pod-security.kubernetes.io/warn-version=latest --overwrite
done
kubectl get ns --show-labels | grep fleet
```{{exec}}

</details>

<details><summary>✦ warn vs audit vs enforce</summary>

- **warn** - clients see a warning on apply; nothing is blocked
- **audit** - violations land in the API audit log; nothing is blocked
- **enforce** - violating Pods are **rejected**

Rolling out `warn` first is the standard adoption path - you are doing the real thing
right now.

</details>
