# Step 2: Initialize BuildSafe

Clone the Go project.

`git clone https://github.com/buildsafedev/examples.git && 
cd examples/go-server-example`{{exec}}

Initialize the project.

`bsf init`{{exec}}

The `bsf init` command automatically detects that it is a Go program and sets up common development and runtime dependencies for it. It generates the necessary flake files, including `bsf.hcl`, which specifies the development and runtime packages.

View the generated `bsf.hcl` file.

`cat bsf.hcl`{{exec}}



