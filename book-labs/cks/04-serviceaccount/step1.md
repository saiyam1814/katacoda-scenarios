# Remove excess access and token mounts

# Scenario

ServiceAccount `reader` and Deployment `worker` in namespace `book-cks-identity` have more API access than required.

Replace Role `reader` rules so the account can only `get` ConfigMap `settings`. It must not list ConfigMaps, read ConfigMap `other`, read Secrets or access ConfigMaps in `default`. Keep the RoleBinding. Disable automatic token mounting on both the ServiceAccount and the Deployment Pod template, then roll out the change. The application does not call the Kubernetes API.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cks-04-serviceaccount/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.



<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-04-serviceaccount/solution.sh
bash /opt/book-labs/cks-04-serviceaccount/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
