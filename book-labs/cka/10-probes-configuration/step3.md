# Scenario — Combine probes, affinity, toleration and resource admission

Book scenario(s): 32.

In `book-cka-probes`, create two-replica Deployment `web` (nginx:1.28.0), required node affinity for book-labs.example/pool=apps and matching NoSchedule toleration. Configure startup/readiness/liveness HTTP probes for `/` on named port http. Requests:100m CPU/64Mi; limits:300m CPU/128Mi. Create LimitRange `container-limits` with a per-container memory maximum of256Mi and Service `web`. Verify a512Mi Pod is rejected by admission.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-10-probes-configuration/verify-step-03.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-10-probes-configuration/solution-step-03.sh
bash /opt/book-labs/cka-10-probes-configuration/solution-step-03.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-10-probes-configuration/solution.sh`. Every step remains independently verifiable after all solutions finish.
