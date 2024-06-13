1. Generate the SBOM in SPDX format:

`bsf att cat bsf-result/attestations.intoto.jsonl --predicate-type spdx --predicate > sbom.json`{{exec}}


2. Scan the SBOM using Trivy:

`nix run "nixpkgs#trivy" -- sbom sbom.json`{{exec}}

Verify that the SBOM has been generated and scanned successfully.

