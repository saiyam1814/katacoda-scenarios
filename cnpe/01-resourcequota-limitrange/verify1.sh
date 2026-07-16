#!/bin/bash
# Exactly one quota and one limitrange
[ "$(kubectl -n squad-nebula get quota -o name | wc -l)" -eq 1 ] || exit 1
[ "$(kubectl -n squad-nebula get limitrange -o name | wc -l)" -eq 1 ] || exit 1

# Quota: correct name and pods=6
[ "$(kubectl -n squad-nebula get quota nebula-pod-cap -o jsonpath='{.spec.hard.pods}' 2>/dev/null)" = "6" ] || exit 1

# LimitRange: correct name and values
LR=$(kubectl -n squad-nebula get limitrange nebula-cpu-defaults -o json 2>/dev/null) || exit 1
echo "$LR" | grep -q '"type": *"Container"' || exit 1
[ "$(echo "$LR" | python3 -c "import json,sys; l=json.load(sys.stdin)['spec']['limits'][0]; print(l.get('defaultRequest',{}).get('cpu',''))")" = "50m" ] || exit 1
[ "$(echo "$LR" | python3 -c "import json,sys; l=json.load(sys.stdin)['spec']['limits'][0]; print(l.get('default',{}).get('cpu',''))")" = "50m" ] || exit 1
[ "$(echo "$LR" | python3 -c "import json,sys; l=json.load(sys.stdin)['spec']['limits'][0]; print(l.get('max',{}).get('cpu',''))")" = "250m" ] || exit 1

# The existing Deployment must be untouched (no resources injected into its spec)
[ "$(kubectl -n squad-nebula get deploy nebula-api -o jsonpath='{.spec.template.spec.containers[0].resources}')" = "{}" ] || exit 1

exit 0
