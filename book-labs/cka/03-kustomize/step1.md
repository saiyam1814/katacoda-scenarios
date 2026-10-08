# Scenario — Render and apply an application overlay

Book scenario(s): 29.

Use the prepared app/base in your lab work directory. Keep the prepared base unchanged. Create app/overlays/prod: prefix prod-, three replicas, nginx:1.28.0, and environment=production labels on workload and Service selectors. Save app/rendered.yaml, apply the overlay, and prove the Service reaches the application.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-03-kustomize/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-03-kustomize/solution-step-01.sh
bash /opt/book-labs/cka-03-kustomize/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-03-kustomize/solution.sh`. Every step remains independently verifiable after all solutions finish.
