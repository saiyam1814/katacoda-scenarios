#!/bin/bash
# Verify that the repository has been cloned successfully
[ -d "gitex-workshop/.git" ] && exit 0 || exit 1