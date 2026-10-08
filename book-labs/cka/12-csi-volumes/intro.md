# CKA — CSI persistence and real filesystem expansion

We will work through 2 related tasks. Each has a separate CHECK and solution. The resources belong to this lab; setup resets them so you can practise again.

**Environment:** A disposable one-node4GB root VM with loop devices and device-mapper linear support. Setup installs LVM utilities and OpenEBS LocalPV LVM1.10.1, creating only a dedicated4Gi sparse file and VG book_cka_csi. This is real block storage, not the CSI host-path test driver.

Wait for Ready before starting. Check setup without leaving the terminal:

```bash
if test -f /tmp/book-labs/cka-12-csi-volumes/error; then
 cat /tmp/book-labs/cka-12-csi-volumes/error
elif test -f /tmp/book-labs/cka-12-csi-volumes/ready; then
 printf 'Ready. Start the scenario.\n'
else
 printf 'Setup is still running; inspect /tmp/book-labs/cka-12-csi-volumes/setup.log.\n'
fi
```{{exec}}

Files and answer evidence are under `~/book-labs/cka-12-csi-volumes`. Only use this lab in its disposable environment. Read `cleanup.sh` before using it on a shared local test cluster.
