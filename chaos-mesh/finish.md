Chaos Mesh is an emerging open source project started in Q4 2019. It is filled with many of the experiment features you would expect to write for Chaos testing. The project is under active development as a [Sandbox project with CNCF](https://www.cncf.io/sandbox-projects/). This Katacoda scenario will be updated as it evolves.

The project has taken the right native architecture path to use the Kubernetes Operator Pattern. By defining a collection of CRDs, its controller accepts experiment declarations from you in the form of YAML manifests. These YAML are expected to be infrastructure as code and part of your CI/CD pipeline along with your other testing formulas.

With these steps you have learned to:

- &#x2714; Install Chaos Mesh onto Kubernetes
- &#x2714; Install and label applications to make them eligible targets for chaos
- &#x2714; Design and deliver chaos experiments
- &#x2714; Observe the chaos engine exercise your experiments against the cluster objects

> In the last year we've seen Chaos Engineering move from a much talked-about idea to an accepted, mainstream approach to improving and assuring distributed system resilience. As organizations large and small begin to implement Chaos Engineering as an operational process, we're learning how to apply these techniques safely at scale. The approach is definitely not for everyone, and to be effective and safe, it requires organizational support at scale. -- [ThoughtWorks Radar](https://www.thoughtworks.com/radar/techniques/chaos-engineering)

## References ##

- [Chaos Mesh project](github.com/chaos-mesh/chaos-mesh)
- [Chaos Mesh documentation](https://chaos-mesh.org/docs/)
- [K8s Chaos Dive, Chaos-Mesh Part 1, Craig Morten](https://dev.to/craigmorten/k8s-chaos-dive-2-chaos-mesh-part-1-2i96)
- [Principles of Chaos Engineering](http://principlesofchaos.org/)
- [Fallacies of Distributed Computing Explained (PDF)](http://www.rgoarchitects.com/Files/fallacies.pdf)

## Related Scenarios
* Kubernetes Pipelines: Consumer-Driven Contracts with Kubernetes
* Kubernetes Serverless: Knative
* Kubernetes Applications: Istio
* Kubernetes Chaos: Pure Chaos
* Kubernetes Chaos: Litmus

------
<p style="width: 100%; text-align: center; padding: 1em; margin: 3em; margin-left: 10em; margin-right: 10em; border-; 1px; border-color: olive;  border-radius: 12px; border-style:outset">
<img align="left" src="./assets/jonathan-johnson.jpg" width="100" style="border-radius: 12px">
For a deeper understanding of these topics and more join <br>[Jonathan Johnson](http://www.dijure.com)<br> at various conferences, symposiums, workshops, and meetups.
<br><br>
<b>Software Architectures ★ Speaker ★ Workshop Hosting ★ Kubernetes & Java Specialist</b>
</p>
