#!/bin/bash
RO=$(kubectl -n shop-core get rollout catalog -o json 2>/dev/null) || exit 1

python3 - "$RO" <<'PYEOF' || exit 1
import json, sys
ro = json.loads(sys.argv[1])
bg = ro["spec"]["strategy"]["blueGreen"]
assert bg["activeService"] == "catalog-active"
assert bg["previewService"] == "catalog-preview"
assert bg.get("autoPromotionEnabled") is False
assert ro["spec"].get("replicas") == 2
PYEOF

[ "$(kubectl -n shop-core get rollout catalog -o jsonpath='{.status.phase}')" = "Healthy" ] || exit 1

# active svc got a rollout hash selector (rollout owns it now)
HASH=$(kubectl -n shop-core get svc catalog-active -o jsonpath='{.spec.selector.rollouts-pod-template-hash}')
[ -n "$HASH" ] || exit 1

exit 0
