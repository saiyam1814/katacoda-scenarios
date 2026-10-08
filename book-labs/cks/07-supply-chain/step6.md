# Sign the release and reject changed content

Use real Cosign to generate a key pair, sign release/manifest.json with a Sigstore bundle and verify it using the trusted public key. Keep private key outside release/. Save release/manifest.bundle.json and release/cosign.pub. Copy and change the manifest to release/changed.json: verification with the same bundle must fail. Use the lab-only password book-lab-key for noninteractive commands; never reuse this key for real releases.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-07-supply-chain/solution.sh
bash /opt/book-labs/cks-07-supply-chain/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
