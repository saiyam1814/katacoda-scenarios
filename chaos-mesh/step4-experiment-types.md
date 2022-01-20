Chaos Mesh project offers a rich selection of experiment types. Currently, here are the choices:

| Category      | Type             | Experiment Description  |
|:-------------:|------------------|-------------------------|
| Pod Lifecycle | Pod Failure      | Killing pods. |
| Pod Lifecycle | Pod Kill         | Pods becoming unavailable. |
| Pod Lifecycle | Container Kill   | Killing containers in pods. |
| Network       | Partition        | Separate Pods into independent subnets by blocking communication between them. |
| Network       | Loss             | Inject network communication loss. |
| Network       | Delay            | Inject network communication latency. |
| Network       | Duplication      | Inject packet duplications. |
| Network       | Corrupt          | Inject network communication corruption. |
| Network       | Bandwidth        | Limit the network bandwidth. |
| I/O           | Delay            | Inject delay during I/O. |
| I/O           | Errno            | Inject error during I/O. |
| I/O           | Delay and Errno  | Inject both delays and errors with I/O. |
| Linux Kernel  |                  | Inject kernel errors into pods. |
| Clock         | Offset           | Inject clock skew into pods. |
| Stress        | CPU              | Simulate pod CPU stress. |
| Stress        | Memory           | Simulate pod memory stress. |
| Stress        | CPU & Memory     | Simulate both CPU and memory stress on Pods. |

You can also use this scenario as a sandbox to create other experiments and experience the growing list of Chaos Mesh features. In the next steps, you will create some experiments.
