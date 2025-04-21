
## step4/verify.sh
```
#!/bin/bash
# Verify ArgoCD Application exists and is synced
for i in {1..30}; do
  status=$(kubectl -n argocd get application gitex-app -o jsonpath='{.status.sync.status}' 2>/dev/null)
  if [[ "$status" == "Synced" ]]; then
    exit 0
  fi
  sleep 2
done
exit 1
```
