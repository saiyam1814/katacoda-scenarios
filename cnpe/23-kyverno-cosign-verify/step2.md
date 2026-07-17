# Prove signed passes, unsigned fails

**Signed** Distroless image - should sail through admission (the first verification
takes a few seconds while Kyverno talks to Rekor):

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ok-signed-web
  namespace: policy-sandbox
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ok-signed-web
  template:
    metadata:
      labels:
        app: ok-signed-web
    spec:
      containers:
        - name: web
          image: gcr.io/distroless/base:debug-nonroot
          command: ["/busybox/sh", "-c", "while true; do sleep 3600; done"]
EOF
```{{exec}}

**Unsigned** image - the admission webhook must reject it:

```bash
cat <<'EOF' | kubectl apply -f - ; echo "exit: $?"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blocked-plain-web
  namespace: policy-sandbox
spec:
  replicas: 1
  selector:
    matchLabels:
      app: blocked-plain-web
  template:
    metadata:
      labels:
        app: blocked-plain-web
    spec:
      containers:
        - name: web
          image: busybox:1.36
          command: ["sh", "-c", "sleep 3600"]
EOF
```{{exec}}

Expected: `admission webhook "mutate.kyverno.svc-fail" denied the request` with your
policy name and `no signatures found` in the message.

Confirm the end state:

```bash
kubectl -n policy-sandbox get deploy,pods
```{{exec}}

<details><summary>✦ Interesting detail - the image got mutated</summary>

```bash
kubectl -n policy-sandbox get pod -l app=ok-signed-web \
  -o jsonpath='{.items[0].spec.containers[0].image}' ; echo
```{{exec}}

Kyverno replaced the tag with the **digest** it verified
(`gcr.io/distroless/base@sha256:…`). That is on purpose: a tag could be re-pointed at
an unsigned image after verification; a digest cannot.

</details>

<details><summary>✦ If the signed image is ALSO denied</summary>

- Check egress: verification needs `rekor.sigstore.dev` and `fulcio.sigstore.dev`
- `kubectl -n kyverno logs deploy/kyverno-admission-controller --tail=30`
- Timeout errors → raise `webhookTimeoutSeconds` (you set 30, the max allowed)

</details>
