#!/bin/bash
if grep -q "curl" bsf.hcl; then
  echo "done"
else
  echo "not done"
fi

