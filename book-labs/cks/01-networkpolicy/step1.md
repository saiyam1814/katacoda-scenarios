# Combine namespace and Pod selectors

# Scenario

The API is running in namespace `book-cks-network`. Create NetworkPolicies in that namespace to deny ingress by default, then allow TCP port `80` to Pods labeled `app=api` only from Pods labeled `access=trusted` in the namespace labeled `team=green`.

Namespace `book-cks-green` contains `trusted` and `untrusted` clients. Namespace `book-cks-blue` contains another `trusted` client. Only the green trusted client may reach `api`. The green trusted client must not reach the `admin` server in the target namespace. Do not change namespace or Pod labels, and do not change the applications.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cks-01-networkpolicy/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.



<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-01-networkpolicy/solution.sh
bash /opt/book-labs/cks-01-networkpolicy/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
