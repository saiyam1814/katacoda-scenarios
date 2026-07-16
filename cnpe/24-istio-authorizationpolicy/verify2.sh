#!/bin/bash
# storefront allowed (bounded retry: policy pushes can briefly interrupt traffic)
OK=0
for _ in 1 2 3 4; do
  OUT=$(kubectl -n web exec storefront -- curl -s --max-time 5 http://checkout.payments.svc:8080/hostname 2>/dev/null)
  echo "$OUT" | grep -q "checkout" && { OK=1; break; }
  sleep 5
done
[ "$OK" = "1" ] || exit 1

# reporting denied (RBAC message or empty/non-200). A connection opened before
# the policy keeps answering on the old Envoy config until it is drained (up to
# ~45s), so poll instead of sampling once. Persistent access still fails.
DENIED=0
for _ in 1 2 3 4 5 6 7 8 9 10 11 12; do
  OUT2=$(kubectl -n batch exec reporting -- curl -s --max-time 5 http://checkout.payments.svc:8080/hostname 2>/dev/null)
  if echo "$OUT2" | grep -qi "denied"; then DENIED=1; break; fi
  if ! echo "$OUT2" | grep -q "checkout"; then DENIED=1; break; fi
  sleep 5
done
[ "$DENIED" = "1" ] || exit 1

exit 0
