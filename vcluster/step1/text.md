# Step 1: Install vCluster CLI

To install vCluster CLI, run the following command:

`curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.20.0-beta.1/vcluster-linux-amd64" && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster`{{exec}}

Verify the installation by checking the vCluster version:

`vcluster --version`{{exec}}

This should output the installed version of vCluster.

