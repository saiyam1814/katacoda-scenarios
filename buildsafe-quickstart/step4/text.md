# Step 4: Add and Update Dependencies

1. Search for the `curl` package:

`bsf search curl`{{exec}}


2. Follow the prompts to add `curl` version 7.84.0 to your development environment and allow minor version updates.

3. Verify that `curl` has been added to the `bsf.hcl` file:

`cat bsf.hcl`{{exec}}


4. Update the project dependencies:

`bsf update`{{exec}}


5. Verify that `curl` is available:

`cat bsf.hcl`{{exec}}



