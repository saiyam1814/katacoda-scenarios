# Scenario — Observe a mounted ConfigMap update

Book scenario(s): 26.

Change only ConfigMap `demo` colour to blue. Wait until `/etc/config/colour` becomes blue in the existing Pod, while its environment variable colour remains green. Do not recreate the Pod.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-10-probes-configuration/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-10-probes-configuration/solution-step-02.sh
bash /opt/book-labs/cka-10-probes-configuration/solution-step-02.sh
```{{exec}}

The kubelet refreshes ordinary ConfigMap volume projections. It does not rewrite the environment of an already running process.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-10-probes-configuration/solution.sh`. Every step remains independently verifiable after all solutions finish.
