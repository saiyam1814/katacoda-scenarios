# Scan an actual image and report exploitable priorities

Trivy 0.75.0 and its real vulnerability database are installed. Scan the digest in `scan-image.txt`, saving full JSON to `reports/image.json` and HIGH/CRITICAL findings to `reports/high-critical.tsv` (ID, package, installed version, fixed version). Include all actual findings; an empty report is valid only when the full scan has no matching vulnerabilities. Record the image digest rather than reporting a tag as immutable.

Scan every regular and init-container image currently used in namespace `book-cks-scan`. Save one real JSON report per distinct image plus `scan-index.json` (image-to-file mapping), `pods.json` and sorted unique affected Pod names in `badimages.txt` under `~/book-labs/cks-07-supply-chain/reports/namespace`. A failed scan must stop the exercise. The provided `scan-namespace.py` shows a reproducible enumeration and scan workflow; review it before running.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-07-supply-chain/solution.sh
bash /opt/book-labs/cks-07-supply-chain/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
