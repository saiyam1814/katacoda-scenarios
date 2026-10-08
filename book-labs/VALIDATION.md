# Full-course local validation

Recorded 8 October 2026. The collection contains **33 grouped labs and 85 checked steps**, with complete mappings for all 69 book scenarios. The [coverage map](COVERAGE.md) identifies each task and verifier.

**28 labs have actual local passes, representing 72 step checks.** Every recorded initial state failed; supplied solutions and relevant cleanup passed. These are local results. [Hosted validation](HOSTED-VALIDATION.md) records Chrome execution separately.

| Local execution set | Labs | Step checks | Evidence |
|---|---:|---:|---|
| CKA application/platform groups | 14 | 38 | [Summary](evidence/local-full-2026-10-08/cka/summary.json) |
| CKS groups: 02, 03, 04, 05, 07, 09 | 6 | 19 | [Summary](evidence/local-full-2026-10-08/cks/summary.json) |
| Infrastructure groups: 03 through 09 | 7 | 14 | [Summary](evidence/infra-local/summary.json) |
| Supporting offline audit-policy exercise | 1 | 1 | [Evidence](evidence/local-full-2026-10-08/offline-audit) |

The remaining five groups require the native host or kernel environment and are exercised through Chrome: kubeadm bootstrap/upgrade, network/metadata isolation, host/kernel security and incident investigation. A hosted pass does not relabel these as a local pass.

CKA testing used dedicated Kubernetes v1.35.0 Linux node containers; scheduling and network tasks used two nodes with Cilium 1.20.1. Volume expansion used OpenEBS LocalPV LVM 1.10.1 and an actual ext4 filesystem growing from 1GiB to 2GiB while retaining PVC identity and data. Metrics Server used verified kubelet TLS. The CKS supply-chain tests executed actual scans, builds, SBOM generation and signing. Infrastructure tests executed real systemd, SSH, kubeadm, etcd, audit, admission and encryption behavior. The linked summaries describe adaptations and distinguish intermediate executions from later final verifier captures.

Dedicated test clusters and credentials were removed after testing. Existing user clusters and Docker workloads were preserved. Evidence excludes kubeconfigs, private keys and tokens.

## Source and regression checks

The [coverage validator](evidence/local-full-2026-10-08/static-validation.log) checks all 33 definitions, supported backends, assets, script syntax, course paths and all 69 chapter mappings. The [collection regression suite](evidence/local-full-2026-10-08/unit-tests.log) has 29 tests; the [infrastructure suite](evidence/local-full-2026-10-08/infrastructure-unit-tests.log) has six tests, including the actual package-index substitutions under pipefail with a large producer. Their logs record the result and time for the current run.

Chrome testing found a Cilium ipBlock identity difference, an early-exit package lookup causing SIGPIPE and a hosted underlay that passes VXLAN on UDP4789 rather than the default8472. Supplied scripts were corrected; affected hosted runs are recorded in the separate hosted report. Later checker improvements are covered by the targeted regression records and current hosted retests; older local runs remain dated evidence. Future source or backend changes require the affected checks to be repeated.

The [original 7 October record](VALIDATION-2026-10-07.md) preserves the earlier 12-lab suite and its mutation tests. Its results apply to that earlier source and do not certify the expanded course.
