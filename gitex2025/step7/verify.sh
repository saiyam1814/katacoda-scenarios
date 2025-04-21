
## step7/verify.sh
```
#!/bin/bash
# Verify that a second pod was created (replicas scaled to 2)
ns=$(kubectl get ingress -A -o jsonpath='{.items[0].metadata.namespace}')
for i in {1..30}; do
  ready=$(kubectl -n "$ns" get deployment -o jsonpath='{.items[0].status.readyReplicas}')
  if [[ "$ready" == "2" ]]; then
    exit 0
  fi
  sleep 5
done
exit 1
```