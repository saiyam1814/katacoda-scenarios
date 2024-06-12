#!/bin/bash
vcluster list --namespace team-x | grep awesome-demo &> /dev/null && echo "done"

