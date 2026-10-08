# CKS - Ingress TLS and service identity

These 2 steps use real components and keep their own verification. Setup prepares intentionally incomplete starting states. Wait for Ready before beginning. Installation failures are setup failures, not solved tasks.

```bash
state=/tmp/book-labs/cks-09-ingress-mtls
if test -f "$state/ready"; then echo 'Ready'; elif test -f "$state/error"; then cat "$state/error"; else tail -n 15 "$state/setup.log"; fi
```{{exec}}

The complete solution is available in each step. The shared solution solves every step; CHECK still evaluates one step at a time. Reset the scenario to repeat from the original conditions.
