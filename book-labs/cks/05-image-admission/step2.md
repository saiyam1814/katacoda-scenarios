# Close the ephemeral-container admission gap

Extend `book-images` to validate UPDATE requests to `pods/ephemeralcontainers`. Every ephemeral-container image must use `registry.k8s.io` and a sha256 digest, just like regular and init containers. The already-running Pod `debug-target` allows a real subresource request. Test one allowed digest reference and one disallowed BusyBox tag using server dry-run, so no debug container is actually launched.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-05-image-admission/solution.sh
bash /opt/book-labs/cks-05-image-admission/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
