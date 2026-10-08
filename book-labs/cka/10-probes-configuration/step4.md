# Scenario — Prove failed readiness excludes an endpoint

Book scenario(s): 32.

Create Pod `unready` in `book-cka-probes`, image nginx:1.28.0, with a readiness HTTP probe at `/missing` and the lab taint toleration. Expose it as Service `unready`. Its container must run but remain unready, and its endpoint must not be marked Ready. Keep the healthy web Deployment.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-10-probes-configuration/verify-step-04.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-10-probes-configuration/solution-step-04.sh
bash /opt/book-labs/cka-10-probes-configuration/solution-step-04.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-10-probes-configuration/solution.sh`. Every step remains independently verifiable after all solutions finish.
