# Hosted Killercoda validation

**7 October 2026 — all 12 labs passed the actual hosted browser flow: six CKA and six CKS.** Each lab reached Ready, rejected its prepared unsolved state, executed the solution code action, and reached **Scenario completed** through CHECK in the [published companion course](https://killercoda.com/saiyampathak/course/book-labs).

The machine-readable record is [hosted results.json](evidence/hosted/results.json). All 12 completion screenshots were inspected when preparing this report. A terminal verifier pass alone was not counted as a browser completion. CKA 01–03 also passed fresh-environment startup/full-flow reruns at source commit `5d079fc`; their three completion screenshots were inspected separately. The completed results file has SHA-256 `92efe2d9d0ba43aac86865629d82c3e36a0f3eeb76c02a57e2606aebd2c287a5`.

## Environment actually observed

The backend is `kubernetes-kubeadm-1node`. The [RBAC session](evidence/hosted/cka-01-rbac.jpg) recorded **Kubernetes v1.36.1**, Ubuntu 24.04.5 LTS and containerd 2.2.1. The [NetworkPolicy setup screenshot](evidence/hosted/cks-01-networkpolicy-before.jpg) shows **Cilium v1.20.1** and a completed policy-enforcement canary. These versions were observed in those sessions, not independently recorded for every lab. They are separate from the earlier local Kubernetes v1.35.0 tests with kindnet or Calico v3.33.0 and from the book's research baseline.

The audit-policy lab runs on the hosted machine but evaluates **24 offline event fixtures**. It does not configure API-server auditing or verify emitted audit logs.

## Recorded browser completions

All rows include setup Ready and solution-code execution. The rejection column describes the deliberately unsolved state, not an infrastructure failure.

| Lab | Initial verification rejected | Browser result | Evidence |
|---|---|---|---|
| [CKA 01 — RBAC](https://killercoda.com/saiyampathak/course/book-labs/01-rbac) | Missing release-bot; exit 1 | Scenario completed | [Completion](evidence/hosted/cka-01-rbac.jpg) |
| [CKA 02 — Service repair](https://killercoda.com/saiyampathak/course/book-labs/02-service-repair) | Wrong Service selector/port; exit 1 | Scenario completed | [Before](evidence/hosted/cka-02-service-repair-before.jpg), [Completion](evidence/hosted/cka-02-service-repair.jpg) |
| [CKA 03 — Kustomize](https://killercoda.com/saiyampathak/course/book-labs/03-kustomize) | Missing production overlay; exit 1 | Scenario completed | [Before](evidence/hosted/cka-03-kustomize-before.jpg), [Completion](evidence/hosted/cka-03-kustomize.jpg) |
| [CKA 04 — Persistent volume](https://killercoda.com/saiyampathak/course/book-labs/04-persistent-volume) | Claim not bound as required | Scenario completed | [Before](evidence/hosted/cka-04-persistent-volume-before.jpg), [Completion](evidence/hosted/cka-04-persistent-volume.jpg) |
| [CKA 05 — Scheduling](https://killercoda.com/saiyampathak/course/book-labs/05-scheduling) | Incorrect requested placement | Scenario completed | [Before](evidence/hosted/cka-05-scheduling-before.jpg), [Completion](evidence/hosted/cka-05-scheduling.jpg) |
| [CKA 06 — Rollout recovery](https://killercoda.com/saiyampathak/course/book-labs/06-rollout-recovery) | Working image/replicas not restored | Scenario completed | [Before](evidence/hosted/cka-06-rollout-recovery-before.jpg), [Completion](evidence/hosted/cka-06-rollout-recovery.jpg) |
| [CKS 01 — NetworkPolicy](https://killercoda.com/saiyampathak/course/book-labs/01-networkpolicy) | All three forbidden paths reachable | Scenario completed | [Fresh before](evidence/hosted/cks-01-networkpolicy-retest-before.jpg), [Completion](evidence/hosted/cks-01-networkpolicy.jpg) |
| [CKS 02 — Pod Security Admission](https://killercoda.com/saiyampathak/course/book-labs/02-pod-security) | Restricted enforcement not pinned to v1.35 | Scenario completed | [Before](evidence/hosted/cks-02-pod-security-before.jpg), [Completion](evidence/hosted/cks-02-pod-security.jpg) |
| [CKS 03 — Runtime hardening](https://killercoda.com/saiyampathak/course/book-labs/03-runtime-hardening) | Required securityContext absent | Scenario completed | [Before](evidence/hosted/cks-03-runtime-hardening-before.jpg), [Completion](evidence/hosted/cks-03-runtime-hardening.jpg) |
| [CKS 04 — ServiceAccount](https://killercoda.com/saiyampathak/course/book-labs/04-serviceaccount) | Reader could get an unauthorized ConfigMap | Scenario completed | [Before](evidence/hosted/cks-04-serviceaccount-before.jpg), [Completion](evidence/hosted/cks-04-serviceaccount.jpg) |
| [CKS 05 — Image admission](https://killercoda.com/saiyampathak/course/book-labs/05-image-admission) | Required admission policy absent | Scenario completed | [Before](evidence/hosted/cks-05-image-admission-before.jpg), [Completion](evidence/hosted/cks-05-image-admission.jpg) |
| [CKS 06 — Audit policy](https://killercoda.com/saiyampathak/course/book-labs/06-audit-policy) | Audit policy file absent | Scenario completed | [Before](evidence/hosted/cks-06-audit-policy-before.jpg), [Completion](evidence/hosted/cks-06-audit-policy.jpg) |

The first RBAC session required a terminal reconnect; pressing Return restored it. The historical note remains in the results. The storage, scheduling, rollout and fresh NetworkPolicy entries explicitly record that the learner terminal remained open. The scheduling entry also records the clean failure diagnostic.

## Fixes found and verified during hosted testing

The initial lab pack was published in `cd12d88`. The following changes were pushed as the browser testing exposed or exercised their behavior:

| Commit | Change and evidence |
|---|---|
| `d25cfb1` | Replaced nested CKA/CKS course groups with direct scenario entries after course navigation failed. Static validation now requires each item to resolve to its own `index.json`. |
| `fc526fe` | Added `/readyz` checks with request/process timeouts and a maximum 180-second preflight; scheduling verification now requires a Scheduled event for the current Pod UID. Regression tests cover a hanging API command and rejection of a previous Pod's event. |
| `1450fd1` | Moved foreground waiting into a subshell so injected exits/options do not close or alter the learner shell. Semantic JSON assertions now report concise `FAIL:` diagnostics. Hosted storage/scheduling/rollout results and shell/diagnostic regression tests cover this behavior. |
| `b8b4672` | Changed NetworkPolicy verification to concurrent traffic probes. It retains the intended HTTP success and two attempts for each of the three forbidden paths; remote completion markers prevent an exec failure being counted as denied traffic. A fresh browser run reached completion. |
| `5d079fc` | Added a clickable setup-status check to every introduction. The audit lab's [status-action screenshot](evidence/hosted/cks-06-audit-policy-status.jpg) records the clicked command and Ready result. |

The NetworkPolicy issue is retained in the evidence: the [earlier run](evidence/hosted/cks-01-networkpolicy-check-failure.jpg) passed directly in **20.400 seconds** while browser CHECK rejected it twice. After the parallel-probe fix, the [fresh run](evidence/hosted/cks-01-networkpolicy.jpg) passed directly in **5.071 seconds** and CHECK reached Scenario completed. These are measured runs, not a guaranteed runtime or a claim about an officially documented platform timeout.

Some earlier screenshots retain older diagnostic output. A delivered source commit or asset hash is not recorded for every completed run, so the suite is not described as all 12 labs being rerun at one identical final commit.

## Fresh-environment CKA regression runs

CKA 01–03 were repeated on fresh hosted environments after the learner-shell and diagnostic fixes. Each recorded regression is tied to `5d079fc` and confirms setup Ready, an open learner terminal, rejection of the unsolved state, solution-code execution and browser completion. Service repair and Kustomize also confirm the clean failure diagnostics. The first RBAC session's reconnect note remains as historical evidence; the fresh run confirmed normal startup without closing the shell.

| Lab | Fresh startup | Unsolved state | Browser completion |
|---|---|---|---|
| CKA 01 — RBAC | [Startup](evidence/hosted/cka-01-rbac-retest-startup.jpg) | [Rejected](evidence/hosted/cka-01-rbac-retest-before.jpg) | [Completed](evidence/hosted/cka-01-rbac-retest.jpg) |
| CKA 02 — Service repair | [Startup](evidence/hosted/cka-02-service-repair-retest-startup.jpg) | [Rejected with clear diagnostic](evidence/hosted/cka-02-service-repair-retest-before.jpg) | [Completed](evidence/hosted/cka-02-service-repair-retest.jpg) |
| CKA 03 — Kustomize | [Startup](evidence/hosted/cka-03-kustomize-retest-startup.jpg) | [Rejected with clear diagnostic](evidence/hosted/cka-03-kustomize-retest-before.jpg) | [Completed](evidence/hosted/cka-03-kustomize-retest.jpg) |

## Current static and regression checks

The [static validation log](evidence/hosted/static-validation.log) records all 12 definitions, local references, course paths, asset references and Bash/Python syntax passing. The [unit-test log](evidence/hosted/unit-tests.log) records **22 tests passed in 14.630 seconds**, covering audit-rule behavior, learner-shell preservation, JSON diagnostics, bounded readiness, current-Pod scheduler events and network probe failure handling/concurrency.

These are separate from the original [local validation record](VALIDATION.md), whose smoke-test, mutation and six-test audit logs remain unchanged. The current regression result does not imply a fresh rerun of all original local cluster or mutation tests.

## Scope and repeat checks

There are no uncompleted labs in this 12-lab hosted suite. The three additional CKA 01–03 reruns are also complete. This validates the companion browser flows, not every scenario in the two books, every possible wrong answer, or live API-server auditing. The new status action is explicitly click-tested in the audit lab; it is not claimed as separately click-tested in every lab.

A future backend, source or asset change requires the affected flow to be checked again: wait for Ready, require unsolved verification to reject, execute the solution, then require browser CHECK completion. Preserve failures and their fixes alongside the final screenshots.
