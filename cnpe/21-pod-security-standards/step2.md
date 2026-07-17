# Find and label the offenders

Warnings appear when Pods are **admitted**, so restart the fleet's Deployments and
watch your terminal:

```bash
for ns in fleet-1 fleet-2 fleet-3 fleet-4; do
  echo "=== $ns ==="
  kubectl -n "$ns" rollout restart deploy 2>&1
done
```{{exec}}

Namespaces whose restart printed a `Warning: would violate PodSecurity "baseline:latest"`
line are your offenders. You can also ask the API server directly without restarting
anything - dry-run any Pod-creating change:

```bash
for ns in fleet-1 fleet-2 fleet-3 fleet-4; do
  echo "=== $ns ==="
  kubectl -n "$ns" get deploy -o yaml | kubectl apply --dry-run=server -f - 2>&1 | grep -i warning || echo "clean"
done
```{{exec}}

Label **only** the offenders:

<details><summary>✅ Solution</summary>

The warnings finger `fleet-2` (hostPath volume) and `fleet-4` (hostNetwork +
privileged):

```bash
kubectl label ns fleet-2 secops.acme/needs-hardening=true --overwrite
kubectl label ns fleet-4 secops.acme/needs-hardening=true --overwrite
kubectl get ns -l secops.acme/needs-hardening=true
```{{exec}}

</details>

<details><summary>✦ What exactly did baseline catch?</summary>

- `fleet-2`: `hostPath` volumes - restricted host filesystem access
- `fleet-4`: `hostNetwork: true` **and** `privileged: true` - both baseline violations
- `fleet-1` / `fleet-3`: plain containers, no host access - baseline-clean
  (they would still fail **restricted**, which demands runAsNonRoot, seccomp, etc.)

</details>
