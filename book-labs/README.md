# CKA and CKS book companion labs

Practice every scenario in the updated books through **33 grouped labs**. Related scenarios share an environment and have separate tasks, worked solutions and CHECKs. The 32 practical labs cover all **38 CKA and 31 CKS scenarios**; the additional offline audit-policy lab helps you practise rule ordering. These are original exercises based on public documentation.

Open the [book companion course on Killercoda](https://killercoda.com/saiyampathak/course/book-labs). Each lab contains everything needed to practise without opening the book. The source is in this repository, so you can also use the scripts while recording videos.

## Find a book scenario

[coverage.json](coverage.json) maps every book scenario to its precise lab steps and verification scripts. The book appendices and [coverage table](COVERAGE.md) provide the reading version. There are 20 labs used by CKA and 14 used by CKS; cluster upgrades and worker operations are shared. The offline `cks/06-audit-policy` is extra practice. The live audit exercise is `infrastructure/07-apiserver-security`.

The course lists individual scenario paths directly because Killercoda uses the final folder name for routing. Every lab uploads its assets to its own `/opt/book-labs/<lab-id>` directory. The published course, source catalog and coverage map are checked together.

## Use a lab

Wait for the terminal's **Ready** message. Read the task, attempt it, and use CHECK. Open the worked solution when needed, then use CHECK again. Every step checks the actual result, including required saved evidence and relevant allowed and denied actions.

Setup failures are distinct from an incorrect answer: inspect the lab's retained `setup.log` and `error` sentinel. Native cluster installation and upgrades need package and image downloads; their introductions give longer setup estimates. The shell wait preserves the learner's terminal and its options.

Labs use the supported single-node, two-node and Ubuntu backends specified in each `index.json`. Hosted Kubernetes can differ from the book's version. Bootstrap and upgrade exercises install their stated patch versions explicitly. Bootstrap uses one worker in Killercoda's supported two-VM environment. The high availability exercise runs three real control-plane containers and a load balancer on one 4GB VM; it proves quorum during member failure. See [infrastructure notes](infrastructure/README.md).

## Local practice and validation

Use a dedicated disposable Linux VM or cluster and read the individual introduction first. Host labs change real services, runtime configuration, control-plane files, storage devices or cluster packages. An API-only kind cluster is insufficient for those prerequisites. The catalog marks host-dependent labs with `execution: host`.

For an API exercise, explicitly select your isolated kubeconfig:

```bash
export KUBECONFIG=/absolute/path/to/disposable-cluster.kubeconfig
bash book-labs/cka/02-service-repair/setup.sh
# Read the task and try it yourself.
bash book-labs/cka/02-service-repair/verify-step-01.sh
# Read the solution before running it.
bash book-labs/cka/02-service-repair/solution.sh
bash book-labs/cka/02-service-repair/verify.sh
```

Work files default to `~/book-labs/<lab-id>` and state/logs to `/tmp/book-labs/<lab-id>`. `BOOK_LAB_WORK_ROOT` and `BOOK_LAB_STATE_ROOT` let isolated tests use separate locations. Apply them consistently to setup, solutions and checks. Application labs can reset their named resources; infrastructure setup guards against accidentally repeating destructive preparation. Read the lab's cleanup instructions before resetting it.

```bash
python3 book-labs/validate.py --require-coverage
python3 -m unittest discover -s book-labs/tests -v
python3 book-labs/smoke-test.py \
  --kubeconfig /absolute/path/to/disposable-cluster.kubeconfig \
  --output /tmp/book-labs-smoke \
  --lab cka-02-service-repair
```

Without `--lab`, the smoke runner selects API exercises. Host execution additionally requires its explicit disposable-host option on Linux. It requires every unsolved step to fail, runs the complete solution, then requires every step to pass. These tests do not establish a hosted browser pass.

## Evidence

[Local validation](VALIDATION.md) and [hosted validation](HOSTED-VALIDATION.md) distinguish source checks, real local runs and Chrome runs through Killercoda. The expanded collection's evidence is under `evidence/local-full-2026-10-08` and `evidence/hosted-full-2026-10-08`. Results from the original 12-lab pack remain dated historical evidence. A terminal check passing and the browser reaching **Scenario completed** are recorded separately.

After changing a lab, test its published assets in a fresh hosted environment. Killercoda can serve older cached source shortly after a push, so confirm that the expected step scripts and task version arrived before counting the run. Verify Ready, the initial failure, the supplied solution and each browser CHECK.

References: [creator documentation](https://killercoda.com/creators), [asset delivery](https://github.com/killercoda/scenario-examples/blob/main/upload-assets/index.json), [course grouping](https://github.com/killercoda/scenario-examples-groups), [standalone scenario requirement](https://killercoda.com/faq).
