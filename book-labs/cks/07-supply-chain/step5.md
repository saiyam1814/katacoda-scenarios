# Generate an SBOM and make an evidence-based release decision

Generate reports/sbom.cdx.json with real Trivy CycloneDX inventory for the digest in scan-image.txt. Scan that inventory to reports/sbom-scan.json. Write exactly BLOCK or PASS to reports/decision.txt: BLOCK if any HIGH or CRITICAL vulnerability exists, PASS otherwise. A valid SBOM without a vulnerability scan is insufficient. Do not assume a fixed count from an older recording.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-07-supply-chain/solution.sh
bash /opt/book-labs/cks-07-supply-chain/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
