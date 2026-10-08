# Deny egress from a namespace

In `book-cks-egress`, deny all outgoing traffic from every Pod. Keep the web service reachable by incoming requests from the separate `book-cks-metadata` namespace. Save the NetworkPolicy as `~/book-labs/cks-01-networkpolicy/deny-egress.yaml`. Test by IP so a DNS failure cannot masquerade as blocking the target HTTP connection.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-01-networkpolicy/solution.sh
bash /opt/book-labs/cks-01-networkpolicy/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>

The deny policy must select every Pod in `book-cks-egress`, not just the client label. The unblocked control request comes from the separate metadata exercise namespace.
