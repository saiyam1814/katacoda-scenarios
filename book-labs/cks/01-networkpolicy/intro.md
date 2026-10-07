# Allow only the intended client traffic

**CKS scenario | Cluster Setup | Suggested time: 15 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

The API is running in namespace `book-cks-network`. Create NetworkPolicies in that namespace to deny ingress by default, then allow TCP port `80` to Pods labeled `app=api` only from Pods labeled `access=trusted` in the namespace labeled `team=green`.

Namespace `book-cks-green` contains `trusted` and `untrusted` clients. Namespace `book-cks-blue` contains another `trusted` client. Only the green trusted client may reach `api`. The green trusted client must not reach the `admin` server in the target namespace. Do not change namespace or Pod labels, and do not change the applications.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.
