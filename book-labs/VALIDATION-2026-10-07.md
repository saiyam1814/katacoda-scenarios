# Validation record

**7 October 2026: all 12 local lab flows passed.** This comprises 11 Kubernetes exercises and one offline audit-policy exercise. Every prepared starting state failed verification, and every supplied solution passed. These are historical local runs; their saved logs and events have not been rewritten to imply a rerun after later fixes.

**All 12 hosted browser flows have now passed.** The published course was tested on Killercoda: setup reached Ready, the unsolved state was rejected, the solution code action ran, and CHECK reached the completion page. Eleven exercises use the hosted Kubernetes cluster; the audit-policy exercise evaluates offline fixtures inside the hosted environment. See [HOSTED-VALIDATION.md](HOSTED-VALIDATION.md) for current evidence and [the published course](https://killercoda.com/saiyampathak/course/book-labs) to run the labs.

## Original local test environments

- All six CKA labs and the four non-network live CKS labs were initially exercised in an isolated kind cluster running **Kubernetes v1.35.0**, using image `kindest/node:v1.35.0` and kindnet.
- The NetworkPolicy lab was tested in a fresh cluster of the same version with default CNI disabled and official **Calico v3.33.0** installed. Its setup canary confirmed that a deny policy blocked a previously working connection and that deleting the policy restored it. Its solution allowed the intended client and denied all three forbidden paths.
- The ServiceAccount lab was additionally rerun successfully on Calico after its RoleBinding check was strengthened.
- The audit-policy lab is an **offline check of 24 representative events**, using the documented restricted JSON subset. It does not configure the API server, validate its full audit-policy grammar or verify emitted audit logs.

The QA cluster was created specifically for this work with a dedicated kubeconfig. It was removed after testing; existing Docker workloads and the user's normal Kubernetes configuration were not changed.

## Wrong-answer checks

Ten live mutations were rejected, then restored and verified:

1. Overbroad Role rules.
2. A ClusterRoleBinding granting cluster-admin to the ServiceAccount's namespace group.
3. An incorrect Service target port.
4. Applied replicas differing from the Kustomize overlay.
5. Incorrect data in the persistent volume.
6. A recovered Deployment with the wrong desired replica count.
7. Permissive PSA enforcement labels.
8. ServiceAccount token automount re-enabled.
9. An image-admission binding set to Audit instead of Deny.
10. NetworkPolicy namespaceSelector and podSelector split into OR peers instead of one AND peer.

The original local testing exposed and corrected three checker problems: selecting a terminating old Pod after rollout, a privileged-Pod probe that failed core validation before reaching PSA, and Service dataplane propagation immediately after restoring a target port. Those corrections select the current Ready Pod, use a structurally valid forbidden Pod, and allow bounded Service convergence.

## Original offline checks and evidence

The standalone validator checked all 12 JSON definitions, Markdown/script references, uploaded assets, group paths, Bash syntax and Python syntax. The saved original unit-test log records six audit tests covering first-match behavior, health-path boundaries, API groups and verbs, nonresource requests, unsupported fields and unmatched requests. New regression tests added during hosted fixes are separate from that historical six-test result.

See [validation-results.json](validation-results.json), [the combined smoke report](evidence/combined-results.json), [mutation results](evidence/mutations.json), [network mutation](evidence/network-mutation.json), [Kubernetes version](evidence/kubernetes-version.json), [Calico version and manifest hash](evidence/calico-version.json), [static checks](evidence/static-validation.log), and [unit-test output](evidence/unit-tests.log). Per-lab setup/before/solution/after logs are also in `evidence/`. These contain no kubeconfig or credentials.

## Hosted testing and subsequent fixes

The 12 recorded browser flows are complete. Its recorded environment includes Kubernetes **v1.36.1** and, in the NetworkPolicy setup screenshot, **Cilium v1.20.1**. The hosted version is independent of both the earlier local Kubernetes v1.35.0 environment and the certification baseline.

The published course was flattened to direct scenario entries (`d25cfb1`). API readiness gained a maximum 180-second preflight and process timeouts, and scheduling events are now checked against the current Pod UID (`fc526fe`). The foreground wait now preserves the interactive learner shell, and resource verification gives concise failure diagnostics (`1450fd1`). NetworkPolicy probes run concurrently, retaining one allowed path and two attempts for each of three denied paths; a fresh hosted run completed after this change (`b8b4672`). A clickable setup-status block was added to every introduction and exercised in the audit lab (`5d079fc`). The hosted evidence records which flows actually completed after these changes; it does not relabel earlier local events as new tests.

See [hosted results](evidence/hosted/results.json) and [HOSTED-VALIDATION.md](HOSTED-VALIDATION.md) for individual screenshots, follow-up rerun scope and limitations. Local tests alone cannot prove hosted asset synchronization, browser actions or runtime behavior. Future backend or asset changes require affected flows to be rerun, including CHECK before and after the solution. The hosted suite does not claim that the entire book or every local wrong-answer mutation was exercised on Killercoda.


## Regression checks after the hosted fixes

The newer [static validation log](evidence/hosted/static-validation.log) records all 12 definitions, local references, course paths, asset references, and Bash/Python syntax passing. The [current unit-test log](evidence/hosted/unit-tests.log) records **22 tests passed in 14.630 seconds**. These cover the original audit subset plus foreground-shell preservation, clear JSON diagnostics, bounded API readiness, current-Pod scheduling events and parallel network verification, including rejection of exec failures as evidence of denied traffic.

The six-test original log above remains unchanged. The current regression log is a separate run; it does not replace the original local cluster smoke tests or imply that all local mutation tests were rerun on Killercoda. CKA 01–03 additionally passed fresh-environment startup/full-flow reruns at `5d079fc`: setup reached Ready, the terminal stayed open, the unsolved state was rejected, the solution action ran, and browser CHECK completed. The Service repair and Kustomize reruns confirmed concise failure diagnostics. The separate `regression` entries and screenshots are linked in [HOSTED-VALIDATION.md](HOSTED-VALIDATION.md).
