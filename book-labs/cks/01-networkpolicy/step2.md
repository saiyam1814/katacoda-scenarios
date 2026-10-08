# Deny egress from one workload

In `book-cks-egress`, deny all outgoing traffic from Pods labelled `app=client`, while leaving the web Deployment unaffected. Save the NetworkPolicy as `~/book-labs/cks-01-networkpolicy/deny-egress.yaml`. Test by IP so a DNS failure cannot masquerade as blocking the target HTTP connection.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-01-networkpolicy/solution.sh
bash /opt/book-labs/cks-01-networkpolicy/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
