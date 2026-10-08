# Run a workload inside gVisor

The real runsc handler is installed and configured. Label the installed node `book-labs.example/runsc=true` and select that label for the sandbox workload. Create RuntimeClass `book-sandbox` using handler `runsc`, then run BusyBox Pod `sandbox` in `book-cks-host` with that class. Save its actual `dmesg` output to `sandbox-runtime.txt` in the work directory. Also create `book-missing` RuntimeClass with unavailable handler `does-not-exist` and Pod `missing`; preserve the failed-sandbox event as `missing-runtime.txt`.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-08-host-security/solution.sh
bash /opt/book-labs/cks-08-host-security/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
