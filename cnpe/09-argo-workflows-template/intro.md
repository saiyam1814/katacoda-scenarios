# Offer a deploy-kit WorkflowTemplate

**Domain:** GitOps and Continuous Delivery &nbsp;|&nbsp; **Suggested time:** 12 minutes

Product squads keep asking the platform team to "just deploy a container". Time to give
them **self-service**: a reusable, parameterized Argo **WorkflowTemplate**.

In namespace **`workflows`**, create WorkflowTemplate **`deploy-kit`**:

- Parameters: **`appName`**, **`targetNs`**, **`count`**, **`containerImage`**
- Runs as ServiceAccount **`workflow-runner`** (already set up with the needed RBAC)
- Contains **one template** named **`ship`** that uses a `resource` step with
  `action: apply` to create a Deployment built from the four parameters

Then submit a run that creates **`catalog-ui`** in **`demo-reef`** with **3 replicas**
of image **`httpd:2.4`**, and prove the Deployment is up.

Click **START** while Argo Workflows installs.
