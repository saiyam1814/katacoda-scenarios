# Investigate the actual audit trail

Read the actual API audit records in `~/book-labs/cks-10-incident-investigation/incident.jsonl`. Preserve that file unchanged. Write `findings.json` with fields `actor`, `sourceIP`, `secretRead` (HTTP code), `crossNamespaceRead` (HTTP code), `deletedPod`, `targetSecret`, and `activity` (chronological list of verbs). Identify what the credential successfully did and what authorization denied. Write a short `response-plan.md` explaining why a request body or Secret value is unnecessary for this investigation, and why deleting only the Pod would not revoke the identity.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-10-incident-investigation/solution.sh
bash /opt/book-labs/cks-10-incident-investigation/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
