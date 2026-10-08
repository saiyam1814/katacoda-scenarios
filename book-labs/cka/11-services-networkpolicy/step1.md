# Scenario — Create and test three Service types

Book scenario(s): 15.

In book-cka-services expose the two web Pods with ClusterIP Service web, NodePort Service node-web using31815, and LoadBalancer Service public-web. These listen on80 and target the named http container port. Also create ClusterIP Service web-alt listening on3231 and targeting the same port80 application. Use the prepared client to test ClusterIP DNS and the node InternalIP:31815. Save loadbalancer-status.txt containing the actual external address, or Pending with a brief explanation when this VM has no load balancer implementation.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-11-services-networkpolicy/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-11-services-networkpolicy/solution-step-01.sh
bash /opt/book-labs/cka-11-services-networkpolicy/solution-step-01.sh
```{{exec}}

A LoadBalancer Service object needs an implementation that allocates an external address. This task requires observing the real state; it does not pretend that a plain VM has a cloud load balancer.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-11-services-networkpolicy/solution.sh`. Every step remains independently verifiable after all solutions finish.
