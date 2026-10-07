# Scenario completed

You have completed **Harden a workload and check the running process**. Repeat the task once without the solution, then explain why the failed state did not meet the requirement.

A manifest is only part of the evidence. `/proc/1/status` confirms the running process UID, capabilities, no-new-privileges and seccomp mode; a writable `/tmp` keeps the application usable.

These companion labs are an initial pack, not the complete CKA or CKS curriculum.
