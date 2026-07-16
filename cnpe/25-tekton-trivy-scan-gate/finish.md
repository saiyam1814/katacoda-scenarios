# Security gate operational! 🎉

CRITICAL CVEs now stop the pipeline **before** deploy — you saw both the gate slam
shut and swing open.

## Key facts to remember

- `trivy image --exit-code 1 --severity CRITICAL <img>` — non-zero exit = failed step =
  failed TaskRun = failed PipelineRun. That chain **is** the gate
- Ordering is part of the security: `deploy.runAfter: [scan]`, or the gate is decorative
- Add `HIGH,CRITICAL` to tighten; `--ignore-unfixed` to reduce noise
- Trivy needs its DB (downloaded on first run, cacheable in a workspace)
- This lab + lab 23 (Kyverno signatures) = the two supply-chain patterns CNPE tests:
  **scan in the pipeline, verify at admission**

📖 This lab is **Chapter 25** of the *CNPE Scenarios and Solutions* book.

🏁 **That's all 25 labs.** Do them again until the muscle memory is boring — that is
what passing feels like.
