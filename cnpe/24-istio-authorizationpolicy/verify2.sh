#!/bin/bash
# storefront allowed (bounded retry: policy pushes can briefly interrupt traffic)
OK=0
for _ in 1 2 3 4; do
  OUT=$(kubectl -n web exec storefront -- curl -s --max-time 5 http://checkout.payments.svc:8080/hostname 2>/dev/null)
  echo "$OUT" | grep -q "checkout" && { OK=1; break; }
  sleep 5
done
[ "$OK" = "1" ] || exit 1

# Require an HTTP policy denial. A failed exec, DNS lookup or connection is not
# evidence that authorization works. Allow time for the policy to propagate.
DENIED=0
for _ in 1 2 3 4 5 6 7 8 9 10 11 12; do
  if STATUS=$(kubectl -n batch exec reporting -c curl -- curl -sS -o /dev/null -w '%{http_code}' --max-time 5 http://checkout.payments.svc:8080/hostname 2>/dev/null); then
    [ "$STATUS" = "403" ] && { DENIED=1; break; }
  fi
  sleep 5
done
[ "$DENIED" = "1" ] || exit 1

exit 0
