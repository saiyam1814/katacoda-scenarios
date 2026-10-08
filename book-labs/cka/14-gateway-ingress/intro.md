# CKA — Gateway routes and Ingress TLS

We will work through 2 related tasks. Each has a separate CHECK and solution. The resources belong to this lab; setup resets them so you can practise again.

**Environment:** A fresh one-node4GB cluster. Setup installs maintained Traefik chart41.6.1 and standard Gateway API1.5.1, with a real cluster-reachable IPv4 address shared by the two providers.

Wait for Ready before starting. Check setup without leaving the terminal:

```bash
if test -f /tmp/book-labs/cka-14-gateway-ingress/error; then
 cat /tmp/book-labs/cka-14-gateway-ingress/error
elif test -f /tmp/book-labs/cka-14-gateway-ingress/ready; then
 printf 'Ready. Start the scenario.\n'
else
 printf 'Setup is still running; inspect /tmp/book-labs/cka-14-gateway-ingress/setup.log.\n'
fi
```{{exec}}

Files and answer evidence are under `~/book-labs/cka-14-gateway-ingress`. Only use this lab in its disposable environment. Read `cleanup.sh` before using it on a shared local test cluster.
