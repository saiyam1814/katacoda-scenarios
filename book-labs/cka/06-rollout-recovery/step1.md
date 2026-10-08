# Scenario — Create and inspect a Deployment

Book scenario(s): 12.

Create Deployment `created` in `book-cka-rollout` with three replicas of `nginx:1.28.0`. Save its live YAML as `~/book-labs/cka-06-rollout-recovery/created.yaml`. Require all replicas Ready and save each created Pod name plus its node name to pods-nodes.txt.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-06-rollout-recovery/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-06-rollout-recovery/solution-step-01.sh
bash /opt/book-labs/cka-06-rollout-recovery/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-06-rollout-recovery/solution.sh`. Every step remains independently verifiable after all solutions finish.
