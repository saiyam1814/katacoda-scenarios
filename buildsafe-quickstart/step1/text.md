# Step 1: Setup and Initialize BuildSafe

Start by setting up BuildSafe on a remote machine:

Install Nix.

`curl https://gist.githubusercontent.com/saiyam1814/28cee97b7afbe53b1a7bf64c9ed935aa/raw/3d710940ca975ecbc989224931c3335327396805/nix.sh | sh`{{exec}}

Start the Nix daemon.

`. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`{{exec}}

Install the bsf CLI.

`nix profile install "github:buildsafedev/bsf"`{{exec}}


Verify the installation by checking the nix profile.

`nix profile list |  grep buildsafedev`{{exec}}



