# Prove the guardrails work

Graders check **end state**, but in real life you should always prove your change behaves.
Run two experiments:

**1. A Pod with no resources should be admitted and receive the `50m` defaults.**

```bash
kubectl -n squad-nebula run default-cpu-pod --image=busybox:1.36 --restart=Never -- sleep 3600
```{{exec}}

Inspect what the LimitRange injected:

```bash
kubectl -n squad-nebula get pod default-cpu-pod \
  -o jsonpath='{.spec.containers[0].resources}' ; echo
```{{exec}}

**2. A Pod requesting `300m` CPU must be rejected (max is `250m`).**

```bash
cat <<'EOF' | kubectl apply -f - ; echo "exit code: $?"
apiVersion: v1
kind: Pod
metadata:
  name: over-max-cpu
  namespace: squad-nebula
spec:
  containers:
    - name: app
      image: busybox:1.36
      command: ["sleep", "3600"]
      resources:
        requests:
          cpu: 300m
        limits:
          cpu: 300m
EOF
```{{exec}}

You should see `forbidden: maximum cpu usage per Container is 250m`.

Leave `default-cpu-pod` running - the verify check looks at it.

<details><summary>✦ Why did the quota not complain?</summary>

The quota only limits the **count** of Pods (max 6). We are at 3 of 6:
2 × `nebula-api` + 1 × `default-cpu-pod`. Try `kubectl -n squad-nebula describe quota`
to see usage vs. hard limit.

</details>
