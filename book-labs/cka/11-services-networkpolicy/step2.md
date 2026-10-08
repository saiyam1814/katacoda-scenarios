# Scenario — Allow only the required namespace, Pod label and port

Book scenario(s): 21.

Create a namespace-wide default-deny ingress policy and NetworkPolicy frontend-only in book-cka-policy. Select all Pods and allow ingress only TCP80 from Pods with role=allowed AND namespaces labelled book-labs.example/team=frontend. Prove trusted frontend traffic succeeds, while wrong-label frontend, same-label other namespace, and trusted traffic to the genuinely listening8080 port all time out.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-11-services-networkpolicy/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-11-services-networkpolicy/solution-step-02.sh
bash /opt/book-labs/cka-11-services-networkpolicy/solution-step-02.sh
```{{exec}}

These are three independent negative traffic tests. Port8080 is open in the application, so its timeout demonstrates policy enforcement rather than a nonexistent listener.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-11-services-networkpolicy/solution.sh`. Every step remains independently verifiable after all solutions finish.
