# Remove excess API access and token mounts

**CKS scenario | Cluster Hardening / Minimize Microservice Vulnerabilities | Suggested time: 12 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

ServiceAccount `reader` and Deployment `worker` in namespace `book-cks-identity` have more API access than required.

Replace Role `reader` rules so the account can only `get` ConfigMap `settings`. It must not list ConfigMaps, read ConfigMap `other`, read Secrets or access ConfigMaps in `default`. Keep the RoleBinding. Disable automatic token mounting on both the ServiceAccount and the Deployment Pod template, then roll out the change. The application does not call the Kubernetes API.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/cks-04-serviceaccount/error; then
  cat /tmp/book-labs/cks-04-serviceaccount/error
elif test -f /tmp/book-labs/cks-04-serviceaccount/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait a moment, then check again.\n'
fi
```{{exec}}
