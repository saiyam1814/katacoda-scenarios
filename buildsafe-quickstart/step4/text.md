# Step 4: Add and Update Dependencies

Search for the `curl` package.

`bsf search curl`{{exec}}


Follow the prompts to add `curl` version 7.84.0 to your development environment and allow minor version updates.

Verify that `curl` has been added to the `bsf.hcl` file.

`cat bsf.hcl`{{exec}}


Update the project dependencies.

`bsf update`{{exec}}


Verify that `curl` is available.

`cat bsf.hcl`{{exec}}



