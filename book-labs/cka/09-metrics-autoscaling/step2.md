# Scenario — Drive a real HPA scale-out

Book scenario(s): 31.

In book-cka-hpa create cpu-app Deployment using registry.k8s.io/hpa-example, initially one replica, each container requesting 50m CPU. Expose HTTP as Service cpu-app. Create an autoscaling/v2 CPU HPA with minimum1, maximum5 and 50% utilization target. Generate sustained HTTP load, wait for at least two replicas and healthy current CPU metrics, then save the live HPA JSON to hpa-scaled.json. Keep the load running for CHECK.

The book uses a 200m CPU request. This hosted VM has one CPU, so use 50m here to leave enough scheduling capacity for all five replicas alongside the system components. The HPA still scales from measured CPU utilization relative to each container’s request.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-09-metrics-autoscaling/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-09-metrics-autoscaling/solution-step-02.sh
bash /opt/book-labs/cka-09-metrics-autoscaling/solution-step-02.sh
```{{exec}}

CPU utilization is calculated relative to the request. After practising, remove the load and observe the stabilization delay before scale-down.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-09-metrics-autoscaling/solution.sh`. Every step remains independently verifiable after all solutions finish.
