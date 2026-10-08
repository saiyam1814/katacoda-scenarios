# CKA — Service exposure and NetworkPolicy isolation

We will work through 2 related tasks. Each has a separate CHECK and solution. The resources belong to this lab; setup resets them so you can practise again.

**Environment:** A disposable cluster with a NetworkPolicy-enforcing CNI. Setup proves enforcement before marking Ready; no mock policy checks.

Wait for Ready before starting. Check setup without leaving the terminal:

```bash
if test -f /tmp/book-labs/cka-11-services-networkpolicy/error; then
 cat /tmp/book-labs/cka-11-services-networkpolicy/error
elif test -f /tmp/book-labs/cka-11-services-networkpolicy/ready; then
 printf 'Ready. Start the scenario.\n'
else
 printf 'Setup is still running; inspect /tmp/book-labs/cka-11-services-networkpolicy/setup.log.\n'
fi
```{{exec}}

Files and answer evidence are under `~/book-labs/cka-11-services-networkpolicy`. Only use this lab in its disposable environment. Read `cleanup.sh` before using it on a shared local test cluster.
