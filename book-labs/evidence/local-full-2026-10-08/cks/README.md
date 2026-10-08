# CKS local validation

These are actual local runs against a dedicated Kubernetes1.35.0 kind cluster. The API-only groups ran with an isolated kubeconfig; Linux tool and seccomp groups ran inside its disposable node. Every recorded step failed before its solution and passed afterward.

Each run summary records setup, solution and per-step timings. The paired log preserves sanitized output from the initial and solved checks. Full setup/solution streams were summarized to avoid bundling credentials or generated signing material. Hosted Chrome completion is tracked separately.
