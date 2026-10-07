# Validation record

**7 October 2026: all 12 local lab flows passed.** This comprises 11 Kubernetes exercises and one offline audit-policy exercise. Every prepared starting state failed verification, and every supplied solution passed. No scenarios have been published or run through the Killercoda creator browser preview.

## Environments actually tested

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

Testing exposed and corrected three checker problems before this record was finalized: selecting a terminating old Pod after rollout, a privileged-Pod probe that failed core validation before reaching PSA, and Service dataplane propagation immediately after restoring a target port. The final checks select the current Ready Pod, use a structurally valid forbidden Pod, and allow bounded Service convergence.

## Offline checks and evidence

The standalone validator checked all 12 JSON definitions, Markdown/script references, uploaded assets, group paths, Bash syntax and Python syntax. Six unit tests cover audit first-match behavior, health-path boundaries, API groups and verbs, nonresource requests, unsupported fields and unmatched requests.

See [validation-results.json](validation-results.json), [the combined smoke report](evidence/combined-results.json), [mutation results](evidence/mutations.json), [network mutation](evidence/network-mutation.json), [Kubernetes version](evidence/kubernetes-version.json), [Calico version and manifest hash](evidence/calico-version.json), [static checks](evidence/static-validation.log), and [unit-test output](evidence/unit-tests.log). Per-lab setup/before/solution/after logs are also in `evidence/`. These contain no kubeconfig or credentials.

## Before publication

Local tests cannot prove Killercoda's asset synchronization, browser actions, image mirrors, current backend runtime/CNI or behavior after a backend version upgrade. Open every scenario in the connected creator environment and repeat CHECK before and after the solution. Record its server version and recheck the pinned PSA standard when the backend changes. The official provider backend version is independent of the certification version.
