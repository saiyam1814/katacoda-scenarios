# Finish compile-release with a kubectl-apply Task

**Domain:** GitOps and Continuous Delivery &nbsp;|&nbsp; **Suggested time:** 12 minutes

Namespace `pipeline-lab` has a Tekton **Pipeline `compile-release`** with two tasks,
`build` and `package`. The `package` Task renders a Kubernetes manifest and emits it as
a **result** named `manifest`. Nothing deploys it - that is your job.

**Your task:**

1. Create Task **`kubectl-apply`** in `pipeline-lab`:
   - Image **`alpine/k8s:1.35.0`**
   - One param **`manifest`** (type string)
   - Writes the param to a file, then runs `kubectl apply -f` on it
2. Add a pipeline task **`apply`** to `compile-release` that:
   - References Task `kubectl-apply`
   - Runs **after both** `build` and `package`
   - Passes `$(tasks.package.results.manifest)` as the `manifest` param
3. Start a **PipelineRun** and wait until it **succeeds**

The pinned image provides kubectl 1.35 and `/bin/sh`, both used by this Task.
The review run uses Kubernetes 1.35.1.

Click **START** while Tekton installs.
