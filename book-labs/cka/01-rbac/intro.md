# Give an application team the right access

**CKA scenario | Cluster Architecture, Installation & Configuration | Suggested time: 8 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

In namespace `book-cka-rbac`, create ServiceAccount `release-bot`, Role `release-manager` and RoleBinding `release-manager`.

The account must be able to `get`, `list`, `watch`, `update` and `patch` Deployments, and `get`, `list`, `watch` ConfigMaps. It must not create or delete Deployments, read Secrets, or manage workloads in `default`. Keep permissions within the requested namespace.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.
