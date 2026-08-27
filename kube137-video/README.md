# kube137 video kit

Everything needed to record the Kubernetes 1.37 walkthrough.

| File | What it is |
| --- | --- |
| `SCRIPT.md` | Timed shooting script, ~10 min, with narration and marked animation cut points |
| `TRANSCRIPT.md` | Every command and its **real** output, captured from a live 1.37.0 run |
| `animations.html` | Four looping cutaway scenes to screen-record and cut in |
| `POSTS.md` | LinkedIn post, X single post, X thread, and a short blog post |

Published animations: https://claude.ai/code/artifact/c077e468-ed28-40ce-b943-39c1ea693eef

## Before you record

1. Open https://killercoda.com/saiyampathak/scenario/kube137
2. Wait for the intro script to print
   `Kubernetes v1.37.0 is up with these alpha/beta gates on:`
   If it says `(plain - alpha gates were NOT applied)`, restart the environment.
3. Warm the image cache by running step 4 and step 5 once, then
   `kubectl delete pod,statefulset,cm --all` and start your real take.
4. Bump the terminal font size. The feature gate strings are long.

## Recovery

`/root/alpha/gate.sh restore` puts the control plane back if a gate experiment wedges it.

## Verified on

Kubernetes v1.37.0, containerd 2.2.1, single node Killercoda Ubuntu box, 27 August 2026.

Two things that do **not** work, and are in the script deliberately:

- `bindMountOptions` never schedules here. `NodeDeclaredFeatures` (GA in 1.37) blocks it
  because containerd 2.2.1 does not advertise the `MountOptions` CRI capability.
- `kubectl rollout status` errors on a `Recreate` StatefulSet. Use the sampling loop in
  `TRANSCRIPT.md` instead, which makes a better shot anyway.
