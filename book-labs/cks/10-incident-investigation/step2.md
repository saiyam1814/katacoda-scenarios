# Revoke access and isolate the affected workload

Remove the compromised identity’s `incident-access` binding. Add NetworkPolicy `quarantine-actor` in `book-cks-incident` denying all ingress and egress for every Pod in the affected namespace. Keep the actor Pod running for investigation. The observer in the separate unaffected namespace `book-cks-incident-control` must still reach `control-web`, and actor must lose that path. Check the identity including its normal service-account groups cannot get the Secret, list Secrets or delete Pods. Save final controls to `containment.yaml` in the work directory.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-10-incident-investigation/solution.sh
bash /opt/book-labs/cks-10-incident-investigation/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
