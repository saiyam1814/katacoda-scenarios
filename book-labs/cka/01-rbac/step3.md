# Scenario — Run a Pod without an API token

Book scenario(s): 24.

Create Ready Pod `web-identity` with image `nginx:1.28.0` and ServiceAccount `demo-sa` in `book-cka-rbac`. Set `automountServiceAccountToken: false`. The web container must have no API token file or projected service-account-token volume.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-01-rbac/verify-step-03.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-01-rbac/solution-step-03.sh
bash /opt/book-labs/cka-01-rbac/solution-step-03.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-01-rbac/solution.sh`. Every step remains independently verifiable after all solutions finish.
