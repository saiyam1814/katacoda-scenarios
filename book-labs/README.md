# CKA and CKS book companion labs

An initial pack of **12 original practice scenarios**: six CKA and six CKS. Each lab is complete on its own, with a task, prepared environment, solution and checks. These are curriculum-aligned practice, not recalled exam questions or a promise of exam similarity.

## Why Killercoda plus scripts

This repository is already connected to Killercoda. The new `book-labs` directory follows its supported `index.json`, Markdown, background setup, foreground wait and verification conventions. Each scenario uploads its own `assets` to `/opt/book-labs/<lab-id>/`. Its root wrappers also work directly from a local checkout, so the same setup, solution and verification scripts can be used for video recording or an isolated local cluster.

Nothing has been pushed or published. A push to the branch connected to Killercoda may publish these scenarios automatically; review and test them in the creator environment first.

## Scenarios

| ID | Task | Main check |
|---|---|---|
| `cka-01-rbac` | Give a release bot limited permissions | Allowed and forbidden authorization requests |
| `cka-02-service-repair` | Repair a selector and target port | Ready endpoints and a real HTTP request |
| `cka-03-kustomize` | Create a production overlay | Unchanged base, rendered output and live rollout |
| `cka-04-persistent-volume` | Repair a Pending claim | Binding plus data read from another Pod |
| `cka-05-scheduling` | Fix a node selector | Ready Pod, matching node and scheduler event |
| `cka-06-rollout-recovery` | Recover a broken rollout | Working image and complete replica convergence |
| `cks-01-networkpolicy` | Restrict ingress to the intended clients | One allowed path, three denied paths, CNI canary |
| `cks-02-pod-security` | Enforce restricted PSA | Secure Pod accepted; privileged and host-network Pods denied |
| `cks-03-runtime-hardening` | Harden the running process | UID, capabilities, no-new-privileges, seccomp and writable scratch |
| `cks-04-serviceaccount` | Minimize RBAC and remove API token mounts | Named-object access and absence of a projected token |
| `cks-05-image-admission` | Enforce registry and digest format with CEL | Positive and negative server-side admission dry runs |
| `cks-06-audit-policy` | Order audit rules safely | 24 offline event cases; no API-server modification |

## Local use

Use a disposable Kubernetes cluster with administrative access. Setup intentionally resets only the lab's named namespaces and resources. The storage lab also manages PV `book-cka-data` and `/var/book-labs/cka-storage` inside its Kubernetes node; the scheduling lab labels a node. The admission lab creates the cluster-scoped policy and binding `book-images`, scoped by its binding to the lab namespace. Do not point these scripts at a production cluster.

Prerequisites: Bash, Python 3, kubectl and an isolated Kubernetes **1.35 or newer** cluster. Use the Linux default seccomp runtime. The network lab needs a CNI that enforces Kubernetes NetworkPolicy; default kind networking does not. The audit lab itself needs only Bash and Python 3.

From the repository root:

```bash
export KUBECONFIG=/absolute/path/to/disposable-cluster.kubeconfig
bash book-labs/cka/02-service-repair/setup.sh
# Read intro.md and solve the task yourself.
bash book-labs/cka/02-service-repair/verify.sh
# If needed, inspect then run the solution.
cat book-labs/cka/02-service-repair/assets/solution.sh
bash book-labs/cka/02-service-repair/solution.sh
bash book-labs/cka/02-service-repair/verify.sh
```

Files are prepared beneath `~/book-labs/<lab-id>` and state/logs beneath `/tmp/book-labs/<lab-id>`. To use different directories, set `BOOK_LAB_WORK_ROOT` and `BOOK_LAB_STATE_ROOT` before **all** commands. Substitute that work root for `~/book-labs` in the task. Setup is repeatable and returns the lab to its starting state. A solution is intended to run after setup; rerun setup before repeating the whole exercise.

Setup creates a `ready` sentinel only when preparation completes. Errors create an `error` sentinel and retain `setup.log`; the foreground wait has a timeout. A failed infrastructure preparation must not be treated as a learner's incorrect solution.

## Validation and smoke tests

```bash
python3 book-labs/validate.py
python3 -m unittest discover -s book-labs/tests -v
python3 book-labs/smoke-test.py \
  --kubeconfig /absolute/path/to/disposable-cluster.kubeconfig \
  --output /tmp/book-labs-smoke \
  --lab cka-02-service-repair
```

Omit `--lab` to exercise all 12. The smoke test checks that the starting state fails, runs the solution, then requires verification to pass. It writes a JSON report and separate logs. After all smoke tests have passed on the same disposable cluster, optional wrong-answer tests are available:

```bash
python3 book-labs/tests/live-mutations.py \
  --kubeconfig /absolute/path/to/disposable-cluster.kubeconfig \
  --smoke-output /tmp/book-labs-smoke
python3 book-labs/tests/network-mutation.py \
  --kubeconfig /absolute/path/to/disposable-cluster.kubeconfig \
  --smoke-output /tmp/book-labs-smoke
```

These deliberately introduce and restore common mistakes. See [VALIDATION.md](VALIDATION.md) for checks actually performed and remaining limitations.

## Killercoda creator check before publication

The backend is `kubernetes-kubeadm-1node` (2 GB). Official documentation on 7 October 2026 lists this backend as Kubernetes 1.36, with 1.37 scheduled for 25 October. The backend cannot be assumed to match the certification version. Record `kubectl version` when testing and revisit PSA version pins and admission APIs when refreshing the book.

Open each scenario in the creator preview, confirm assets arrive, wait for Ready, run CHECK before solving, apply the supplied solution and run CHECK again. Also inspect terminal copy/execute actions and the expandable solution. Local smoke tests cannot confirm Killercoda asset synchronization, browser behavior, image mirrors or its exact CNI/runtime.

The solution and all necessary task information are included inside each scenario; learners do not need to buy or open the book. No changes were made to existing scenarios or to the unrelated `zero-to-rag` directory.

References: [Killercoda creator documentation](https://killercoda.com/creators), [official asset example](https://github.com/killercoda/scenario-examples/blob/main/upload-assets/index.json), [scenario grouping](https://github.com/killercoda/scenario-examples-groups), [standalone-scenario requirement](https://killercoda.com/faq), [Calico on kind](https://docs.tigera.io/calico/latest/getting-started/kubernetes/kind).
