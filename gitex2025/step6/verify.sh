
## step6/verify.sh
```bash
#!/bin/bash
# Verify the application is accessible via HTTP (status 200)
ns=$(kubectl get ingress -A -o jsonpath='{.items[0].metadata.namespace}')
name=$(kubectl get ingress -A -o jsonpath='{.items[0].metadata.name}')
host=$(kubectl -n $ns get ingress $name -o jsonpath='{.spec.rules[0].host}')
code=$(curl -s -o /dev/null -w "%{http_code}" http://$host)
[ "$code" == "200" ] && exit 0 || exit 1
