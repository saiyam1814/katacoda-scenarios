# Require an approved registry and immutable image digest

# Scenario

Namespace `book-cks-images` has label `book-labs.example/image-policy=enforce`. Use `admissionregistration.k8s.io/v1` to create ValidatingAdmissionPolicy `book-images` and binding `book-images`.

For Pod CREATE and UPDATE requests in this namespace, require every regular and init container image to match `registry.k8s.io/<path>@sha256:<64 lowercase hexadecimal characters>`. Reject tags and all other registries. Set `failurePolicy: Fail` and binding action `Deny`. Limit the binding to the labeled namespace. The checker uses server-side dry runs; no image download is needed.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cks-05-image-admission/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.



<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-05-image-admission/solution.sh
bash /opt/book-labs/cks-05-image-admission/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
