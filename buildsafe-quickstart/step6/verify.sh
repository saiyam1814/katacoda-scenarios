#!/bin/bash
if which go &> /dev/null && curl --version; then
  echo "done"
else
  echo "not done"
fi

