
## step5/verify.sh
```
#!/bin/bash
# Verify that the Ingress host has been patched (not default)
host=$(kubectl get ingress -A -o jsonpath='{.items[0].spec.rules[0].host}')
if [[ -n "$host" && "$host" != *"example"* && "$host" != *"localhost"* ]]; then
  exit 0
else
  exit 1
fi
```
