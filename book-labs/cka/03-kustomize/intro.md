# Create a production Kustomize overlay

**CKA scenario | Cluster Architecture, Installation & Configuration / Workloads & Scheduling | Suggested time: 12 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

The base is in `~/book-labs/cka-03-kustomize/base`. Create an overlay at `~/book-labs/cka-03-kustomize/overlays/prod` without changing the base.

The overlay must deploy into `book-cka-kustomize`, prefix names with `prod-`, run three replicas of `web` using `nginx:1.28.0`, and add label `environment: prod` to the Deployment and Pod template. Apply the overlay. The resulting Deployment must be named `prod-web` and all three replicas must be available.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.
