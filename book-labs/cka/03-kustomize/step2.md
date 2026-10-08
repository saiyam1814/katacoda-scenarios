# Scenario — Patch and install a real metrics component

Book scenario(s): 29.

The prepared metrics/base contains the pinned official Metrics Server v0.8.1 manifests and a public trust bundle for this VM’s real kubelet serving certificate. Create metrics/overlay that changes only the metrics-server CPU request to 200m. Save metrics/rendered.yaml, apply it, and obtain live metrics. Keep kubelet certificate verification enabled.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-03-kustomize/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-03-kustomize/solution-step-02.sh
bash /opt/book-labs/cka-03-kustomize/solution-step-02.sh
```{{exec}}

The fixture adds the real kubelet certificate chain and a hostname matching its SAN. The learner overlay changes the CPU request without weakening TLS.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-03-kustomize/solution.sh`. Every step remains independently verifiable after all solutions finish.
