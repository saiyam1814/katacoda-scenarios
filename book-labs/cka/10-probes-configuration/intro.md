# CKA — Configuration, probes, resource limits and placement

We will work through 4 related tasks. Each has a separate CHECK and solution. The resources belong to this lab; setup resets them so you can practise again.

**Environment:** A disposable cluster; setup adds one named NoSchedule taint to its node and cleanup removes it.

Wait for Ready before starting. Check setup without leaving the terminal:

```bash
if test -f /tmp/book-labs/cka-10-probes-configuration/error; then
 cat /tmp/book-labs/cka-10-probes-configuration/error
elif test -f /tmp/book-labs/cka-10-probes-configuration/ready; then
 printf 'Ready. Start the scenario.\n'
else
 printf 'Setup is still running; inspect /tmp/book-labs/cka-10-probes-configuration/setup.log.\n'
fi
```{{exec}}

Files and answer evidence are under `~/book-labs/cka-10-probes-configuration`. Only use this lab in its disposable environment. Read `cleanup.sh` before using it on a shared local test cluster.
