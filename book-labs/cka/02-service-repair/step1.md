# Scenario — Repair the Service and client resolver

Book scenario(s): 35.

In `book-cka-service`, restore HTTP from `client` to `web.book-cka-service.svc.cluster.local`. Repair the selector, target port and client DNS configuration. Keep the existing web Deployment. Save a short diagnosis naming each fault to `~/book-labs/cka-02-service-repair/causes.txt`.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-02-service-repair/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-02-service-repair/solution-step-01.sh
bash /opt/book-labs/cka-02-service-repair/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-02-service-repair/solution.sh`. Every step remains independently verifiable after all solutions finish.
