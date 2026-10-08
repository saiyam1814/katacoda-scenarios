# Require mTLS and authorize a service identity

In `book-cks-mesh`, require STRICT mTLS for every workload in the namespace. Allow requests only from identity `cluster.local/ns/book-cks-mesh/sa/caller`; the meshed `other` identity must receive403 and the unmeshed `plain` Pod in `book-cks-plain` must fail. Keep the caller request successful. Save the caller Envoy cluster configuration in `mesh-clusters.json` and issued certificate information in `mesh-certificates.json` under the work directory.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-09-ingress-mtls/solution.sh
bash /opt/book-labs/cks-09-ingress-mtls/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
