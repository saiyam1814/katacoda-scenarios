# Trigger a Tekton Pipeline from a Webhook

**Domain:** GitOps and Continuous Delivery &nbsp;|&nbsp; **Suggested time:** 14 minutes

Pipeline **`build-ship`** in namespace `ci-otter` runs fine when someone creates a
PipelineRun by hand. The Git server should do that instead, via webhook.

Create the Tekton Triggers trio in `ci-otter`:

1. **TriggerTemplate `build-ship-tt`** — has a param **`gitrevision`** and a
   `resourcetemplate` that creates a PipelineRun of `build-ship`
   (generateName `build-ship-`, passing the revision through)
2. **TriggerBinding `build-ship-tb`** — maps the webhook JSON field **`body.after`**
   to param `gitrevision`
3. **EventListener `build-ship-el`** — serves the webhook using ServiceAccount
   **`tekton-triggers`** (already prepared), wiring the binding to the template

Then smoke-test with `curl` and confirm a PipelineRun starts and succeeds.

Click **START** while both Tekton controller sets install.
