# Give Sam only the required permissions

ServiceAccount `sam` in `book-cks-secrets` is overprivileged. Replace its excess binding with permissions to get only Secret `database` and create Deployments in this namespace. Sam must not list Secrets, get Secret `other`, delete Deployments or read Secrets in `default`. Test authorization including normal ServiceAccount groups.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-04-serviceaccount/solution.sh
bash /opt/book-labs/cks-04-serviceaccount/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
