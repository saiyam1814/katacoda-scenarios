# Scenario — Recover a workload through events and endpoints

Book scenario(s): 38.

In `book-cka-incident`, restore two available replicas of `web` and HTTP through its Service. Fix the unavailable image to `nginx:1.28.0`, ConfigMap reference to `app-config`, requests to 100m CPU/64Mi memory, limit to 128Mi memory, and Service targetPort to named port `http`. Create a test Pod `client`. Save four causes and observed recovery to `~/book-labs/cka-02-service-repair/incident.txt`.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-02-service-repair/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-02-service-repair/solution-step-02.sh
bash /opt/book-labs/cka-02-service-repair/solution-step-02.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-02-service-repair/solution.sh`. Every step remains independently verifiable after all solutions finish.
