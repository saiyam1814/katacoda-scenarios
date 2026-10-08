# Block metadata and preserve application access

In `book-cks-metadata`, stop client Pods (`app=client`) from reaching the real training HTTP endpoint at `169.254.169.254`. Keep DNS and HTTP Service `web` working. Use an IPv4 egress NetworkPolicy with an exception for the metadata /32; do not delete routes or stop the endpoint. The endpoint runs outside the Kubernetes Pod and host network namespaces and contains only synthetic training text.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-01-networkpolicy/solution.sh
bash /opt/book-labs/cks-01-networkpolicy/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
