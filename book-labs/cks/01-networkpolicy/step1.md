# Combine namespace and Pod selectors

# Scenario

The API is running in namespace `book-cks-network`. Create NetworkPolicies in that namespace to deny ingress by default, then allow TCP port `80` to Pods labeled `app=api` from either of these peers: Pods labeled `access=trusted` in the namespace labeled `team=green`, or Pods labeled `demo=test` in the protected namespace `book-cks-network`.

Namespace `book-cks-green` contains `trusted` and `untrusted` clients. Namespace `book-cks-blue` contains another `trusted` client. `book-cks-network` also contains `local-approved` (`demo=test`) and `local-unapproved` (`demo=other`); `book-cks-blue` contains a second `local-approved` (`demo=test`). Both the green trusted client and the protected namespace's local-approved client must reach `api`. The other clients must remain blocked, including the same `demo=test` label in blue. Neither allowed client may reach the `admin` server in the target namespace.

Use one peer containing both namespace and Pod selectors for the first path (AND), and a separate Pod-only peer for the local path (OR). The Pod-only peer applies only within the NetworkPolicy's own namespace. Do not change namespace or Pod labels, and do not change the applications.

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
