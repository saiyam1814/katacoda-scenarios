# Wire it into the Pipeline and run it

Edit the Pipeline so a third task `apply` runs after **both** existing tasks:

```plain
kubectl -n pipeline-lab edit pipeline compile-release
```{{copy}}

Add under `spec.tasks`:

```yaml
- name: apply
  taskRef:
    name: kubectl-apply
  runAfter: [build, package]
  params:
    - name: manifest
      value: $(tasks.package.results.manifest)
```{{copy}}

Then start a run and follow it:

```bash
tkn pipeline start compile-release -n pipeline-lab --showlog
```{{exec}}

When it finishes, confirm the end state - the Deployment the pipeline applied:

```bash
tkn pipelinerun list -n pipeline-lab
kubectl -n pipeline-lab get deploy compiled-web
```{{exec}}

<details><summary>✦ If the run fails</summary>

- `tkn pipelinerun logs -f -n pipeline-lab` - read the failing step's output
- `error validating data` → your heredoc mangled the manifest - use
  `printf '%s\n' "$(params.manifest)"`
- `deployments.apps is forbidden` → the TaskRun pod's ServiceAccount lacks RBAC - 
  in this lab the `default` SA in `pipeline-lab` is already bound to a Role that
  allows Deployments
- A task result must be **consumed with the exact syntax**
  `$(tasks.<task-name>.results.<result-name>)` - typos fail at validation time

</details>

<details><summary>✅ Solution - full pipeline patch</summary>

```bash
kubectl -n pipeline-lab apply -f - <<'EOF'
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: compile-release
  namespace: pipeline-lab
spec:
  tasks:
    - name: build
      taskRef:
        name: build
    - name: package
      taskRef:
        name: package
    - name: apply
      taskRef:
        name: kubectl-apply
      runAfter: [build, package]
      params:
        - name: manifest
          value: $(tasks.package.results.manifest)
EOF
tkn pipeline start compile-release -n pipeline-lab --showlog
```{{exec}}

</details>
