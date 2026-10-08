# Scenario — Extract the correct container and previous-instance logs

Book scenario(s): 19.

Save only the current logs of container `c2` in Pod `logs-demo` to `~/book-labs/cka-08-static-pods-logs/c2.txt`. Save the previous instance of `crash` container `app` to `previous.txt`. Keep the prepared Pods for verification.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-08-static-pods-logs/verify-step-03.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-08-static-pods-logs/solution-step-03.sh
bash /opt/book-labs/cka-08-static-pods-logs/solution-step-03.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-08-static-pods-logs/solution.sh`. Every step remains independently verifiable after all solutions finish.
