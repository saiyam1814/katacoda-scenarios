# Scenario — Find the highest memory consumer from live metrics

Book scenario(s): 8.

Inspect live node and Pod metrics. Across all namespaces, save the namespace and highest memory-consuming Pod name (two space-separated fields) to highest-memory.txt in this lab’s work directory. The answer must come from current usage, not its declared resource request.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-09-metrics-autoscaling/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-09-metrics-autoscaling/solution-step-01.sh
bash /opt/book-labs/cka-09-metrics-autoscaling/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-09-metrics-autoscaling/solution.sh`. Every step remains independently verifiable after all solutions finish.
