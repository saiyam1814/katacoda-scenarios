# Finish compile-release with a kubectl-apply Task

**Domain:** GitOps and Continuous Delivery &nbsp;|&nbsp; **Suggested time:** 12 minutes

Namespace `pipeline-lab` has a Tekton **Pipeline `compile-release`** with two tasks,
`build` and `package`. The `package` Task renders a Kubernetes manifest and emits it as
a **result** named `manifest`. Nothing deploys it — that is your job.

**Your task:**

1. Create Task **`kubectl-apply`** in `pipeline-lab`:
   - Image **`bitnamilegacy/kubectl:1.28.9`**
   - One param **`manifest`** (type string)
   - Writes the param to a file, then runs `kubectl apply -f` on it
2. Add a pipeline task **`apply`** to `compile-release` that:
   - References Task `kubectl-apply`
   - Runs **after both** `build` and `package`
   - Passes `$(tasks.package.results.manifest)` as the `manifest` param
3. Start a **PipelineRun** and wait until it **succeeds**

*(The original scenario used `bitnami/kubectl:1.29` — Bitnami moved its versioned
public tags to the `bitnamilegacy` archive in 2025, so the lab pins that. The task
writes a file inside the step, so the image must ship a shell — `rancher/kubectl`
does not.)*

Click **START** while Tekton installs.
