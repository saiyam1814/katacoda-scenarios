# Run it against a bad and a good image

**Round 1 — the vulnerable image.** Trivy downloads its CVE database on first run
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

`Error from server (NotFound)` for `shipped` is **success** here — the gate held.

**Round 2 — the clean image:**

```bash
tkn pipeline start build-ship -n ci-otter \
  -p image=gcr.io/distroless/static:nonroot --showlog
```{{exec}}

This one sails through — distroless static has nothing to CVE — and `deploy` runs:

```bash
tkn pipelinerun list -n ci-otter
kubectl -n ci-otter get deploy shipped
```{{exec}}

<details><summary>✦ If the scan step itself errors</summary>

- `TOOMANYREQUESTS` from the DB registry → rerun; or add
  `--db-repository public.ecr.aws/aquasecurity/trivy-db` to the trivy command
- Timeouts: first DB download needs network headroom — the run may take 2–3 minutes
- To scan without a DB fetch each run, real platforms cache the DB in a workspace —
  the book chapter shows how

</details>
