# Fire the webhook

Port-forward the listener Service and POST a fake Git push:

```bash
kubectl -n ci-otter port-forward svc/el-build-ship-el 8080:8080 >/dev/null 2>&1 &
sleep 3
curl -s -X POST http://127.0.0.1:8080 \
  -H 'Content-Type: application/json' \
  -d '{"after": "4f2c1ab"}' | python3 -m json.tool
```{{exec}}

A JSON response with an `eventListener` field means the event was accepted.
Now watch the PipelineRun it spawned:

```bash
tkn pipelinerun list -n ci-otter
tkn pipelinerun logs --last -f -n ci-otter
```{{exec}}

The log should print `building and shipping revision 4f2c1ab` — the value travelled
from your JSON body through the binding into the pipeline. 

<details><summary>✦ If nothing happens</summary>

- `kubectl -n ci-otter logs deploy/el-build-ship-el --tail=20` — the listener logs every
  event and every rejection reason
- `couldn't create resource` → RBAC — the listener SA must be able to create
  PipelineRuns (pre-wired here via the two `tekton-triggers-eventlistener-*` bindings)
- Empty revision? Your binding must read `$(body.after)` — exactly the field you POSTed

</details>
