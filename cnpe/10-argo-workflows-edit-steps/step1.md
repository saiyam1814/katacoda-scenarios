# Insert the ready-check step

Open the definition:

```plain
cat /root/release-checker.yaml
```{{exec}}

Note the **steps syntax**: `steps:` is a list of *lists*. Each outer item
(`- - name: ...`) is a **sequential** stage; multiple entries in the same inner list
would run **in parallel**. You need a new sequential stage in the middle.

Edit with `vim /root/release-checker.yaml` (or `nano`), then submit:

```bash
argo submit /root/release-checker.yaml -n workflows --watch
```{{exec}}

The watch view should show three nodes finishing in order:
`deploy` → `ready-check` → `test`, and finally `Status: Succeeded`.

<details><summary>✦ Tip - the two edits</summary>

**Edit 1** - in the `main` template's `steps`, insert a middle stage:

```yaml
steps:
  - - name: deploy
      template: deploy
  - - name: ready-check
      template: wait-ready
  - - name: test
      template: test
```{{copy}}

**Edit 2** - append the new template under `templates:`:

```yaml
- name: wait-ready
  container:
    image: rancher/kubectl:v1.28.0
    command: [kubectl]
    args: [rollout, status, deploy/checkout-api, -n, stage-coral, --timeout=90s]
```{{copy}}

(The image ships only the `kubectl` binary - there is no shell in it, so the
command must invoke `kubectl` directly, like the existing `deploy` template does.)

Mind the indentation - templates sit at the same level as `deploy` and `test`.

</details>

<details><summary>✅ Solution - full file</summary>

```bash
cat <<'EOF' > /root/release-checker.yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: release-checker-
  namespace: workflows
spec:
  entrypoint: main
  serviceAccountName: workflow-runner
  templates:
    - name: main
      steps:
        - - name: deploy
            template: deploy
        - - name: ready-check
            template: wait-ready
        - - name: test
            template: test

    - name: deploy
      container:
        image: rancher/kubectl:v1.28.0
        command: [kubectl]
        args: [-n, stage-coral, rollout, restart, deploy/checkout-api]

    - name: wait-ready
      container:
        image: rancher/kubectl:v1.28.0
        command: [kubectl]
        args: [rollout, status, deploy/checkout-api, -n, stage-coral, --timeout=90s]

    - name: test
      container:
        image: busybox:1.36
        command: [sh, -c]
        args:
          - echo "smoke tests passed"
EOF
argo submit /root/release-checker.yaml -n workflows --watch
```{{exec}}

</details>
