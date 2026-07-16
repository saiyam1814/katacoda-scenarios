# Fail the Pipeline when an Image has CRITICAL CVEs

**Domain:** Security and Policy Enforcement &nbsp;|&nbsp; **Suggested time:** 14 minutes

Pipeline **`build-ship`** in `ci-otter` resolves an image (task `image`, which emits
result **`image-url`**) and deploys it (task `deploy`). There is **no security gate**
between them. Compliance noticed.

**Your task:**

1. Create Task **`scan-image`** in `ci-otter`:
   - Param **`image`** (string)
   - Runs **Trivy** (image `aquasec/trivy:0.58.1`) with
     `--exit-code 1 --severity CRITICAL` so the step **fails when CRITICAL CVEs exist**
2. Wire a pipeline task **`scan`** into `build-ship`:
   - After `image`, **before** `deploy` (deploy must `runAfter` the scan)
   - Scanning `$(tasks.image.results.image-url)`
3. Prove the gate:
   - Run with **`nginx:1.16`** (from 2019 - full of CRITICAL CVEs) → PipelineRun **fails**,
     nothing deployed
   - Run with **`gcr.io/distroless/static:nonroot`** → **succeeds**, deploy runs

Click **START** while Tekton installs.
