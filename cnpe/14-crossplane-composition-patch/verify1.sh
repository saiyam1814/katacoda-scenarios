#!/bin/bash
set -euo pipefail
kubectl get composition xwebapp-kubernetes -o json | python3 -c '
import json,sys
c=json.load(sys.stdin)["spec"]
assert c["mode"]=="Pipeline" and "resources" not in c
step=next(p for p in c["pipeline"] if p["functionRef"]["name"]=="function-patch-and-transform")
r=next(r for r in step["input"]["resources"] if r["name"]=="app-deployment")
assert r["base"]["kind"]=="Deployment"
pairs={(p.get("fromFieldPath"),p.get("toFieldPath")) for p in r["patches"]}
required={("metadata.namespace", "metadata.namespace"), ("spec.containerImage", "spec.template.spec.containers[0].image"), ("spec.desiredReplicas", "spec.replicas"), ("spec.appName", "spec.selector.matchLabels.app"), ("spec.appName", "metadata.name"), ("spec.appName", "spec.template.metadata.labels.app")}
assert required <= pairs, required-pairs
'
exit 0
