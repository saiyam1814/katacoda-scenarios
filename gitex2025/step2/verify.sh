
## step2/verify.sh
``````bash```
#!/bin/bash
# Verify ingress-nginx Service is NodePort on 30080
type=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.spec.type}')
port=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
if [[ "$type" == "NodePort" && "$port" == "30080" ]]; then
  exit 0
else
  exit 1
fi
```