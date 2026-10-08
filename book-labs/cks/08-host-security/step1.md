# Remediate actual CIS benchmark findings

Run installed kube-bench 0.16.0 with its supplied `cis-1.12` profile and checks `1.1.3,1.3.2`. Fix controller-manager manifest permissions and disable its profiling flag. Preserve the manifest structure and wait for the replacement process. Save a fresh JSON report as `~/book-labs/cks-08-host-security/cis-after.json`. This profile is explicitly selected: upstream does not yet map the hosted Kubernetes minor; these two controls remain applicable. Do not treat all other profile checks as certified compatibility.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-08-host-security/solution.sh
bash /opt/book-labs/cks-08-host-security/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
