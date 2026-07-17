# Create the WorkflowTemplate

Check the controller and the prepared RBAC:

```plain
kubectl -n argo get pods
kubectl -n workflows get sa workflow-runner
kubectl auth can-i create deployments -n demo-reef \
  --as=system:serviceaccount:workflows:workflow-runner
```{{exec}}

Now build `deploy-kit`. Structure to aim for:

- `spec.serviceAccountName: workflow-runner`
- `spec.entrypoint: ship`
- `spec.arguments.parameters` - the four parameter names
- one template `ship` with matching `inputs.parameters` and a `resource:` block - 
  `action: apply` plus an inline `manifest: |` where every dynamic field references
  an input parameter (Argo's curly-brace syntax: `inputs.parameters.appName` wrapped
  in double braces)

<details><summary>✦ Tip - resource templates</summary>

A `resource` template makes the Workflow itself do `kubectl <action>` on a manifest:

```yaml
- name: ship
  resource:
    action: apply
    manifest: |
      apiVersion: apps/v1
      kind: Deployment
      ...
```{{copy}}

Argo substitutes double-braced `inputs.parameters.<name>` expressions inside the
manifest string before applying it.

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: deploy-kit
  namespace: workflows
spec:
  serviceAccountName: workflow-runner
  entrypoint: ship
  arguments:
    parameters:
      - name: appName
      - name: targetNs
      - name: count
      - name: containerImage
  templates:
    - name: ship
      inputs:
        parameters:
          - name: appName
          - name: targetNs
          - name: count
          - name: containerImage
      resource:
        action: apply
        manifest: |
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: {{inputs.parameters.appName}}
            namespace: {{inputs.parameters.targetNs}}
          spec:
            replicas: {{inputs.parameters.count}}
            selector:
              matchLabels:
                app: {{inputs.parameters.appName}}
            template:
              metadata:
                labels:
                  app: {{inputs.parameters.appName}}
              spec:
                containers:
                  - name: main
                    image: {{inputs.parameters.containerImage}}
EOF
```{{exec}}

```plain
kubectl -n workflows get workflowtemplate deploy-kit
```{{exec}}

</details>
