#!/bin/bash
kubectl get pods | grep nginx &> /dev/null && echo "done"

