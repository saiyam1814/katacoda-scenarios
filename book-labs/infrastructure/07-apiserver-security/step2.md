# Enforce a working ImagePolicyWebhook and fail closed

A local TLS service already runs as `cks16-policy` on `https://127.0.0.1:9443/check`. Inspect `/etc/kubernetes/image-policy/server.py`. In namespace `cks16` it permits exactly `busybox:1.37.0` and `nginx:1.28.0-alpine`, while preserving other namespaces. Its TLS files are in the same directory.

Create a webhook kubeconfig and AdmissionConfiguration. Enable ImagePolicyWebhook, use allow/deny cache TTL 1 second and `defaultAllow: false`, and mount the configuration read-only. Preserve audit logging from step 1. Create a Ready Pod `allowed` using `busybox:1.37.0` with `sleep 3600`. Prove an unapproved image is rejected and admission fails closed while the service is stopped, then restore the service. Existing Pods must keep running.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-07-apiserver-security/solution2.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-07-apiserver-security/solution2.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-07-apiserver-security/verify2.sh
```{{exec}}
