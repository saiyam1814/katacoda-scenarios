# Write the kubectl-apply Task

Study what exists — especially how `package` declares its result:

```plain
kubectl -n pipeline-lab get pipeline compile-release -o yaml | grep -A8 "tasks:"
kubectl -n pipeline-lab get task package -o yaml | grep -B2 -A4 results
```{{exec}}

Create Task `kubectl-apply` (API `tekton.dev/v1`). Requirements again:

- param `manifest`, type `string`
- image `bitnamilegacy/kubectl:1.28.9`
- write the param to a file, `kubectl apply -f` that file

<details><summary>✦ Tip — params inside scripts</summary>

Inside a Task step, `$(params.manifest)` expands to the raw string. Quote it carefully
when writing to a file:

```sh
printf '%s\n' "$(params.manifest)" > /tmp/out.yaml
```{{copy}}

`printf` survives multi-line YAML; `echo` may mangle it.

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: kubectl-apply
  namespace: pipeline-lab
spec:
  params:
    - name: manifest
      type: string
  steps:
    - name: apply
      image: bitnamilegacy/kubectl:1.28.9
      script: |
        #!/bin/sh
        set -eu
        printf '%s\n' "$(params.manifest)" > /tmp/out.yaml
        kubectl apply -f /tmp/out.yaml
EOF
```{{exec}}

```plain
kubectl -n pipeline-lab get task kubectl-apply
```{{exec}}

</details>
