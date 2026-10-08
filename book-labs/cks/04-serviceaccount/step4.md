# Use a short-lived token with an isolated kubeconfig

Create `~/book-labs/cks-04-serviceaccount/reader.kubeconfig` containing only the `reader` identity from `book-cks-identity`, with a short-lived TokenRequest token. Use it to retrieve ConfigMap `settings`; it must fail to retrieve ConfigMap `other` and list Secrets. Do not copy administrator client credentials into this file.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-04-serviceaccount/solution.sh
bash /opt/book-labs/cks-04-serviceaccount/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
