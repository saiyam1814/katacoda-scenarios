#!/bin/bash
nix profile list | grep -q 'github:buildsafedev/bsf' && echo "done"

