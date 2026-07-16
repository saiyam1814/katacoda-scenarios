# Create the scan Task and wire the gate

Study the pipeline you are extending:

```plain
kubectl -n ci-otter get pipeline build-ship -o yaml | grep -A20 "tasks:"
```{{exec}}

<details><summary>✦ Tip — the two moving parts</summary>

1. A Task whose step exits non-zero on findings — Trivy does this natively:
   `trivy image --exit-code 1 --severity CRITICAL <image>`
2. Ordering: `scan` runs `runAfter: [image]`; **`deploy` must change** to
   `runAfter: [scan]` — otherwise the gate can be bypassed in parallel

</details>

<details><summary>✅ Solution</summary>

The scan Task:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: scan-image
  namespace: ci-otter
spec:
  params:
    - name: image
      type: string
  steps:
    - name: trivy
      image: aquasec/trivy:0.58.1
      script: |
        #!/bin/sh
        set -eu
        echo "scanning $(params.image) for CRITICAL CVEs..."
        trivy image --exit-code 1 --severity CRITICAL --scanners vuln "$(params.image)"
EOF
```{{exec}}

The rewired pipeline (scan sits between image and deploy):

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: build-ship
  namespace: ci-otter
spec:
  params:
    - name: image
      type: string
  tasks:
    - name: image
      taskRef:
        name: resolve-image
      params:
        - name: image
          value: $(params.image)
    - name: scan
      taskRef:
        name: scan-image
      runAfter: [image]
      params:
        - name: image
          value: $(tasks.image.results.image-url)
    - name: deploy
      taskRef:
        name: deploy-image
      runAfter: [scan]
      params:
        - name: image
          value: $(tasks.image.results.image-url)
EOF
```{{exec}}

</details>
