# Create the CR and prove validation

Apply the contract file:

```bash
kubectl apply -f /root/checkout-express.yaml
```{{exec}}

Use the short name - this is how the grader (and your users) will look:

```bash
kubectl get ff -n flags-lab
```{{exec}}

Now prove the schema actually protects the API. Both of these must **fail**:

```bash
# rolloutPercent out of range
kubectl apply -n flags-lab -f - <<'EOF' || echo "-> rejected (good)"
apiVersion: toggle.acme.dev/v1beta1
kind: FeatureFlag
metadata:
  name: bad-percent
spec:
  key: some.flag
  enabled: true
  rolloutPercent: 150
EOF
```{{exec}}

```bash
# missing required field 'enabled'
kubectl apply -n flags-lab -f - <<'EOF' || echo "-> rejected (good)"
apiVersion: toggle.acme.dev/v1beta1
kind: FeatureFlag
metadata:
  name: no-enabled
spec:
  key: some.flag
  rolloutPercent: 10
EOF
```{{exec}}

<details><summary>✦ Going further (not graded)</summary>

Real platform CRDs also add: `additionalPrinterColumns` (nice `kubectl get` output),
a `status` subresource, and CEL `x-kubernetes-validations` rules for cross-field logic.
The book chapter shows all three.

</details>
