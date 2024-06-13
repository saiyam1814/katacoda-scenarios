#!/bin/bash
nix profile list | grep -q 'buildsafedev/bsf' && echo "done"

