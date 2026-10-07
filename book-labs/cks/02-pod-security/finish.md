# Scenario completed

You have completed **Enforce restricted Pod Security Admission**. Repeat the task once without the solution, then explain why the failed state did not meet the requirement.

PSA operates at admission. Namespace labels do not evict existing Pods, so create or recreate the workload after enforcing the policy.

These companion labs are an initial pack, not the complete CKA or CKS curriculum.
