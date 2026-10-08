# Use a short-lived token with an isolated kubeconfig

Disable automatic token mounts on ServiceAccount `default` in `book-cks-identity`; create BusyBox1.37.0 Pod `default-probe` without a Pod-level automount override and verify it receives no API token. Create `~/book-labs/cks-04-serviceaccount/reader.kubeconfig` containing only the `reader` identity from `book-cks-identity`, with a short-lived TokenRequest token. Use it to retrieve ConfigMap `settings`; it must fail to retrieve ConfigMap `other` and list Secrets. Do not copy administrator client credentials into this file.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-04-serviceaccount/solution.sh
bash /opt/book-labs/cks-04-serviceaccount/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>

After all CHECKs pass, delete the local credential copy: `rm -f ~/book-labs/cks-04-serviceaccount/reader.kubeconfig`. The file is mode0600 while present and contains a short-lived token; cleanup removes it after the access tests.
