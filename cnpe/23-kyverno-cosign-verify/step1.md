# Create the ClusterPolicy

Check Kyverno is healthy:

```plain
kubectl -n kyverno get pods
```{{exec}}

Now the policy. The `verifyImages` rule type does the heavy lifting; your job is to
wire the keyless attestor correctly.

<details><summary>✦ Tip - verifyImages skeleton</summary>

```yaml
rules:
  - name: ...
    match:
      any:
        - resources:
            kinds: [Pod]
    verifyImages:
      - imageReferences: ["*"]
        attestors:
          - entries:
              - keyless:
                  issuer: ...
                  subject: ...
                  rekor:
                    url: ...
```{{copy}}

Kyverno auto-generates matching rules for Deployments/StatefulSets/etc. from the Pod
match (autogen) - so applying a bad **Deployment** is denied too, not just bare Pods.

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: supply-chain-signoff
spec:
  validationFailureAction: Enforce
  background: false
  webhookTimeoutSeconds: 30
  rules:
    - name: require-keyless-cosign
      match:
        any:
          - resources:
              kinds: [Pod]
      verifyImages:
        - imageReferences: ["*"]
          attestors:
            - entries:
                - keyless:
                    issuer: "https://accounts.google.com"
                    subject: "keyless@distroless.iam.gserviceaccount.com"
                    rekor:
                      url: https://rekor.sigstore.dev
EOF
```{{exec}}

```bash
kubectl get clusterpolicy supply-chain-signoff \
  -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' ; echo
```{{exec}}

</details>
