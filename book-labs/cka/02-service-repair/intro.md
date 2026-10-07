# Find why the Service is not working

**CKA scenario | Troubleshooting / Services & Networking | Suggested time: 10 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

Deployment `web` in namespace `book-cka-service` is healthy, but Service `web` does not return the application.

Fix the existing Service so TCP port `80` reaches the `web` Pods on container port `80`. Keep the Service name and ClusterIP. Do not change the Deployment labels. From the existing `client` Pod, `wget -qO- http://web` must return the NGINX welcome page.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/cka-02-service-repair/error; then
  cat /tmp/book-labs/cka-02-service-repair/error
elif test -f /tmp/book-labs/cka-02-service-repair/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait a moment, then check again.\n'
fi
```{{exec}}
