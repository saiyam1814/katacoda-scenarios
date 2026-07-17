# Create the trigger trio

Confirm the pipeline works the manual way first - this is your baseline:

```bash
tkn pipeline start build-ship -n ci-otter -p gitrevision=manual-test --showlog
```{{exec}}

Now build the three objects. Data flows:

**webhook JSON** → *TriggerBinding* extracts fields → *TriggerTemplate* stamps out a
PipelineRun → controller runs it. The *EventListener* is the HTTP front door that ties
bindings to templates.

<details><summary>✦ Tip - the three shapes</summary>

- TriggerTemplate: `spec.params` + `spec.resourcetemplates[]` (an inline PipelineRun;
  reference params with the `tt.params.<name>` curly-brace syntax)
- TriggerBinding: `spec.params[]` with `value: $(body.<jsonpath>)`
- EventListener: `spec.serviceAccountName` + `spec.triggers[].bindings/template`

All three: API group `triggers.tekton.dev/v1beta1`.

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: build-ship-tt
  namespace: ci-otter
spec:
  params:
    - name: gitrevision
      default: main
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: build-ship-
      spec:
        pipelineRef:
          name: build-ship
        params:
          - name: gitrevision
            value: $(tt.params.gitrevision)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: build-ship-tb
  namespace: ci-otter
spec:
  params:
    - name: gitrevision
      value: $(body.after)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: build-ship-el
  namespace: ci-otter
spec:
  serviceAccountName: tekton-triggers
  triggers:
    - name: on-push
      bindings:
        - ref: build-ship-tb
      template:
        ref: build-ship-tt
EOF
```{{exec}}

The controller materializes the listener as a Deployment + Service named
`el-build-ship-el`:

```plain
kubectl -n ci-otter get deploy,svc
```{{exec}}

</details>
