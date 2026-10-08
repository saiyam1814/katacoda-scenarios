# Infrastructure book labs

These nine groups cover CKA 1, 10, 11, 20, 23, 27 and 37, plus CKS 6, 7, 16, 24, 25 and 31. Each step changes real host or cluster state and has a behavioral verifier. Use a fresh disposable environment for each group; these scripts are not safe to run against your workstation or a cluster you need.

The `index.json` files select supported Killercoda backends. Bootstrap, upgrade and worker operations use the real two-VM Kubernetes backend (controlplane and node01). HA uses three real kubeadm control-plane containers and a load balancer on an Ubuntu4GB VM because Killercoda does not offer a three-control-plane VM backend. Its shared VM and single load balancer are explicit lab simplifications. The task still joins three etcd members and proves a fresh API write while one member is stopped.

Use each step's `solutionN.sh` after trying the task; `solution.sh` solves all steps sequentially. Checks are `verifyN.sh`. Wrapper scripts work from a checkout or from the assets uploaded to `/opt/book-labs/infra-<folder>`. Foreground waiting runs in a child shell and cannot exit the learner's terminal. The setup log and error/ready files live under `/tmp/book-labs/infra-<folder>`.

Bootstrap pins Kubernetes1.35.9 and Cilium1.20.2. Upgrade reconstructs a fresh1.34.12 cluster before upgrading one minor; it does not downgrade the existing cluster in place. Package and image downloads make this group's setup the slowest (roughly10–15 minutes on a normal mirror). The one-hour free-session limit includes setup time. Leave time for both steps; slow-mirror behavior still needs hosted validation.

The coverage map and exact validation distinctions are maintained in `kubernetes-scenario-books/research/infrastructure-full-lab-map.json`. Local execution in privileged node containers exercises real Kubernetes/systemd operations but does not establish compatibility with Killercoda's native VMs. Hosted results must be recorded separately.
