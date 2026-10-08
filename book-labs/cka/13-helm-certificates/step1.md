# Scenario — Install, upgrade and roll back a Helm release

Book scenario(s): 28.

Render and install Jetstack cert-manager chart v1.20.4 as book-cert-manager in book-cka-cert-manager with CRDs enabled and one controller replica. Save cert-manager-rendered.yaml. Upgrade to two controller replicas with the same chart version, wait for health, then roll back to revision1. Keep the resulting three-revision history and working release.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-13-helm-certificates/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-13-helm-certificates/solution-step-01.sh
bash /opt/book-labs/cka-13-helm-certificates/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-13-helm-certificates/solution.sh`. Every step remains independently verifiable after all solutions finish.
