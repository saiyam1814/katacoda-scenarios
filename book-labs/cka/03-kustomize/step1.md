# Scenario

The base is in `~/book-labs/cka-03-kustomize/base`. Create an overlay at `~/book-labs/cka-03-kustomize/overlays/prod` without changing the base.

The overlay must deploy into `book-cka-kustomize`, prefix names with `prod-`, run three replicas of `web` using `nginx:1.28.0`, and add label `environment: prod` to the Deployment and Pod template. Apply the overlay. The resulting Deployment must be named `prod-web` and all three replicas must be available.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cka-03-kustomize/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.

<details><summary>Solution</summary>

The complete solution is available inside the environment. Read it first, then run it if needed:

```bash
cat /opt/book-labs/cka-03-kustomize/solution.sh
bash /opt/book-labs/cka-03-kustomize/solution.sh
```{{exec}}

Use `kubectl kustomize` to inspect rendered resources before applying. Built-in Kustomize needs no separate binary.

</details>
