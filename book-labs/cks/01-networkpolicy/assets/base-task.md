# Scenario

The API is running in namespace `book-cks-network`. Create NetworkPolicies in that namespace to deny ingress by default, then allow TCP port `80` to Pods labeled `app=api` only from Pods labeled `access=trusted` in the namespace labeled `team=green`.

Namespace `book-cks-green` contains `trusted` and `untrusted` clients. Namespace `book-cks-blue` contains another `trusted` client. Only the green trusted client may reach `api`. The green trusted client must not reach the `admin` server in the target namespace. Do not change namespace or Pod labels, and do not change the applications.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cks-01-networkpolicy/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.

<details><summary>Solution</summary>

The complete solution is available inside the environment. Read it first, then run it if needed:

```bash
cat /opt/book-labs/cks-01-networkpolicy/solution.sh
bash /opt/book-labs/cks-01-networkpolicy/solution.sh
```{{exec}}

Put `namespaceSelector` and `podSelector` in the same peer entry for AND semantics. Two separate entries allow either condition. The CNI must enforce NetworkPolicy; API acceptance alone is not evidence.

</details>
