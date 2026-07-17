# Create the Server (and watch it default-deny)

Check the mesh first - every Pod should carry a `linkerd-proxy`. Modern Linkerd runs
it as a **native sidecar** (an init container with `restartPolicy: Always`), so look
in `initContainers`:

```bash
kubectl -n payments get pod -l app=checkout \
  -o jsonpath='init: {.items[0].spec.initContainers[*].name}{"\n"}main: {.items[0].spec.containers[*].name}{"\n"}'
kubectl -n batch exec reporting -c curl -- curl -s --max-time 5 http://checkout.payments.svc:8080/hostname ; echo
```{{exec}}

Now describe the port with a **Server** - Linkerd's way of saying "this port is
policy-managed":

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: policy.linkerd.io/v1beta3
kind: Server
metadata:
  name: checkout
  namespace: payments
spec:
  podSelector:
    matchLabels:
      app: checkout
  port: 8080
  proxyProtocol: HTTP/1
EOF
```{{exec}}

</details>

Probe again - **both** callers, even the legit one:

```bash
echo "storefront:"; kubectl -n web exec storefront -c curl -- curl -s --max-time 5 http://checkout.payments.svc:8080/hostname || echo "DENIED"
echo "reporting:";  kubectl -n batch exec reporting -c curl -- curl -s --max-time 5 http://checkout.payments.svc:8080/hostname || echo "DENIED"
```{{exec}}

Everything is denied now. **A Server with no authorization = deny-all for that port.**
That is intentional - you declared the port policed but haven't said who may talk.
Step 2 opens the door for exactly one identity.
