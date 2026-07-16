# Default-deny ingress

First prove the problem — from the *unrelated* namespace, the API answers:

```bash
kubectl -n other-squad exec squad-client -- \
  curl -s --max-time 5 http://api.tenant-red.svc:8080/hostname ; echo
```{{exec}}

Now create NetworkPolicy **`deny-all-ingress`** in `tenant-red` that selects **every Pod**
and denies **all ingress** (do not restrict egress here).

<details><summary>✦ Tip</summary>

An **empty `podSelector: {}`** selects all Pods in the namespace.
Listing `Ingress` under `policyTypes` while defining **no** `ingress` rules means:
"ingress is policed, and nothing is allowed".

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: tenant-red
spec:
  podSelector: {}
  policyTypes: ["Ingress"]
EOF
```{{exec}}

Re-run the probe — it must now time out:

```bash
kubectl -n other-squad exec squad-client -- \
  curl -s --max-time 5 http://api.tenant-red.svc:8080/hostname || echo BLOCKED
```{{exec}}

</details>
