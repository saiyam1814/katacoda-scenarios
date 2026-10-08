# Scenario completed

You have completed **Order audit rules without logging Secret bodies**. Repeat the task once without the solution, then explain why the failed state did not meet the requirement.

Audit policy rules use first-match semantics. Put Secret protection ahead of broad request-body rules. Live auditing additionally needs API-server policy and log flags, mounts, permissions and an observed audit event; those host changes are deliberately outside this file exercise.

Continue with the live API-server security group for audit configuration and observed events. This supporting exercise covers policy ordering only.
