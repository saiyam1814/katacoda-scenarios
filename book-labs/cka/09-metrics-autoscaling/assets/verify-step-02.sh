#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-09-metrics-autoscaling
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-hpa get hpa cpu-app -o json | json_assert 'd["apiVersion"]=="autoscaling/v2" and d["spec"]["minReplicas"]==1 and d["spec"]["maxReplicas"]==5 and d["spec"]["scaleTargetRef"]["name"]=="cpu-app" and d["spec"]["scaleTargetRef"]["apiVersion"]=="apps/v1" and d["spec"]["scaleTargetRef"]["kind"]=="Deployment" and d["spec"]["metrics"]==[{"type":"Resource","resource":{"name":"cpu","target":{"type":"Utilization","averageUtilization":50}}}] and d["status"].get("currentReplicas",0)>=2 and any(c["type"]=="ScalingActive" and c["status"]=="True" for c in d["status"].get("conditions",[])) and d["status"].get("currentMetrics")' 'Require a working CPU HPA that actually scaled out'
assert_deploy_ready book-cka-hpa cpu-app
kubectl -n book-cka-hpa get deployment cpu-app -o json | json_assert 'd["spec"]["template"]["spec"]["containers"][0]["resources"]["requests"]["cpu"]=="200m"' 'Set the CPU request used by utilization metrics'
test -s "$WORK_DIR/hpa-scaled.json" || fail 'Save the observed HPA JSON'
uid=$(kubectl -n book-cka-hpa get hpa cpu-app -o jsonpath='{.metadata.uid}')
kubectl -n book-cka-hpa get events --field-selector "involvedObject.uid=$uid,reason=SuccessfulRescale" -o json | json_assert 'len(d["items"])>0' 'Require a rescale performed by this HPA, not only a manual replica change'
pass "Step 2: Drive a real HPA scale-out"
