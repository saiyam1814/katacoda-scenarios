# Step 1: Setup and Initialize BuildSafe

Start by setting up BuildSafe on a remote machine:

1. Install Nix:

`curl https://gist.githubusercontent.com/saiyam1814/28cee97b7afbe53b1a7bf64c9ed935aa/raw/3d710940ca975ecbc989224931c3335327396805/nix.sh | sh`{{exec}}

2. Start the Nix daemon:

`. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`{{exec}}

3. Install the bsf CLI:

`nix profile install "github:buildsafedev/bsf"`{{exec}}


4. Verify the installation by checking the bsf version:

`bsf -h`{{exec}}



