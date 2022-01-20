<img align="right" width="400" src="./assets/chaos-mesh.png">

Chaos Mesh is a cloud native Chaos Engineering platform that orchestrates chaos on Kubernetes environments. At the current stage, it has the following components:

- Chaos Operator: the core component for chaos orchestration; fully open source.
- Chaos Dashboard: a Web UI for managing, designing, and monitoring Chaos Experiments; under development.

Chaos Mesh is a versatile chaos engineering solution that features all-around fault injection methods for complex systems on Kubernetes, covering faults in Pod, network, file system, and even the kernel.

Choas Mesh is one of the better chaos engines for Kubernetes because:

1. In a short amount of time there has been heavy community support and it's a CNCF sandbox project.
1. It's a native experience to Kubernetes leveraging the Operator Pattern and CRDs permitting IaC with your pipelines.
1. If you have followed the best practices by applying plenty of labels and annotations to your Deployments, then there is no need to make modifications to your apps for your chaos experiments.
1. There are a wide variety of experiment types, not just Pod killing.
1. Installs with a Helm chart and you have complete control over the engine with CRDs.

Don't let the project name _mesh_ misguide you. This project is unrelated to _services meshes_ like Istio and Conduit. Hopefully, in the future, they will leverage the features of a service mesh, but for now, they are unrelated.

In this scenario you will learn how to:

- Install Chaos Mesh onto Kubernetes.
- Install and label applications to make them eligible targets for chaos.
- Design and deliver chaos experiments.
- Observe the chaos engine exercise your experiments against the cluster objects.
