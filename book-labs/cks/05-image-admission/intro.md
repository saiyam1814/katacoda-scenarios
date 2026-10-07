# Enforce image registry and digest rules with CEL

**CKS scenario | Supply Chain Security | Suggested time: 18 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

Namespace `book-cks-images` has label `book-labs.example/image-policy=enforce`. Use `admissionregistration.k8s.io/v1` to create ValidatingAdmissionPolicy `book-images` and binding `book-images`.

For Pod CREATE and UPDATE requests in this namespace, require every regular and init container image to match `registry.k8s.io/<path>@sha256:<64 lowercase hexadecimal characters>`. Reject tags and all other registries. Set `failurePolicy: Fail` and binding action `Deny`. Limit the binding to the labeled namespace. The checker uses server-side dry runs; no image download is needed.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/cks-05-image-admission/error; then
  cat /tmp/book-labs/cks-05-image-admission/error
elif test -f /tmp/book-labs/cks-05-image-admission/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait a moment, then check again.\n'
fi
```{{exec}}
