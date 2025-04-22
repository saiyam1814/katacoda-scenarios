
## step3/verify.sh
```
#!/bin/bash
# Verify ArgoCD server Service is NodePort on 30443
nodeport=$(kubectl get svc argocd-server -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
type=$(kubectl  get svc argocd-server -o jsonpath='{.spec.type}')
if [[ "$type" == "NodePort" && "$nodeport" == "30164" ]]; then
  exit 0
else
  exit 1
fi
```