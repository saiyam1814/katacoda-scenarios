# Run it against a bad and a good image

**Round 1 - the vulnerable image.** Trivy downloads its CVE database on first run
(~1 minute), then fails the run:

```bash
tkn pipeline start build-ship -n ci-otter \
  -p image=nginx:1.16 --showlog
```{{exec}}

Expected ending: the scan step prints a wall of CRITICAL CVEs and the PipelineRun
reports `Failed`. Confirm nothing was deployed:

```bash
tkn pipelinerun list -n ci-otter
kubectl -n ci-otter get deploy shipped 2>&1
```{{exec}}

`Error from server (NotFound)` for `shipped` is **success** here - the gate held.

**Round 2 - the clean image:**

```bash
tkn pipeline start build-ship -n ci-otter \
  -p image=gcr.io/distroless/static:nonroot --showlog
```{{exec}}

If the scan finds no CRITICAL vulnerabilities, the run succeeds and `deploy` runs.
Image tags and vulnerability databases change, so inspect the report rather than
assuming this image will always pass:

```bash
tkn pipelinerun list -n ci-otter
kubectl -n ci-otter get deploy shipped
```{{exec}}

<details><summary>✦ If the scan step itself errors</summary>

- `TOOMANYREQUESTS` from the DB registry → rerun; or add
  `--db-repository public.ecr.aws/aquasecurity/trivy-db` to the trivy command
- Timeouts: first DB download needs network headroom - the run may take 2–3 minutes
- To avoid downloading the database for each run, a pipeline can mount a shared
  workspace at Trivy's cache directory. That configuration is outside this exercise.

</details>
