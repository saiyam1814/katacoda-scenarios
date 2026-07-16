# Allow the edge gateway and DNS

Create NetworkPolicy **`allow-api-from-edge`** in `tenant-red`:

- Applies to Pods labelled **`app=api`**
- **Ingress:** only from namespaces labelled **`purpose=edge`**, only **TCP 8080**
- **Egress:** allow **UDP 53** (DNS) so the api Pods can still resolve names

Check the labels you will match on:

```plain
kubectl get ns --show-labels | grep -E "NAME|edge|squad|red"
```{{exec}}

<details><summary>✦ Tip</summary>

`namespaceSelector` matches **namespace labels** — not names. If you must match a
namespace by name, use the built-in label `kubernetes.io/metadata.name: <name>`.

Careful with YAML structure: `- namespaceSelector: … ports: …` inside **one** list item
means "that namespace AND that port". Two separate list items would mean OR.

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-from-edge
  namespace: tenant-red
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes: ["Ingress", "Egress"]
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              purpose: edge
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
EOF
```{{exec}}

Prove the four outcomes:

```bash
echo "--- edge-client -> api (should ANSWER):"
kubectl -n ingress-gw exec edge-client -- curl -s --max-time 5 http://api.tenant-red.svc:8080/hostname && echo OK
echo "--- squad-client -> api (should BLOCK):"
kubectl -n other-squad exec squad-client -- curl -s --max-time 5 http://api.tenant-red.svc:8080/hostname || echo BLOCKED
echo "--- api -> DNS (should RESOLVE):"
kubectl -n tenant-red exec deploy/api -- nslookup kubernetes.default.svc.cluster.local | head -2
```{{exec}}

</details>
