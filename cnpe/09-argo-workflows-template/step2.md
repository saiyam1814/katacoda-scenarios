# Submit a run and verify the result

Submit a workflow **from** the template, passing the squad's request as parameters:

```bash
argo submit --from workflowtemplate/deploy-kit -n workflows \
  -p appName=catalog-ui \
  -p targetNs=demo-reef \
  -p count=3 \
  -p containerImage=httpd:2.4 \
  --watch
```{{exec}}

When the workflow shows `Succeeded`, verify the actual outcome — the thing the grader
scores:

```bash
kubectl -n demo-reef get deploy catalog-ui
kubectl -n demo-reef rollout status deploy/catalog-ui --timeout=120s
```{{exec}}

<details><summary>✦ If the workflow fails</summary>

- `argo list -n workflows` then `argo get <name> -n workflows` — the failed node shows
  the kubectl error
- `Error (exit code 1): deployments.apps is forbidden` → RBAC: the Workflow ran with
  the wrong ServiceAccount (did you set `serviceAccountName: workflow-runner`?)
- `workflowtaskresults.argoproj.io is forbidden` → the executor RBAC is missing —
  in this lab it is pre-created for `workflow-runner`, so re-check the SA name

</details>
