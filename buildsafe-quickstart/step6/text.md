# Step 6: Create and Verify Development Shell

1. Create a development shell:

`bsf develop`{{exec}}


2. Verify that the Go binary is available in the development shell:

`which go`{{exec}}

3. Verify that `curl` is available in the development shell:

`curl -V`{{exec}}

The development shell ensures that all specified development dependencies are available in an isolated environment, preventing system dependency conflicts.


