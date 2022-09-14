#!/bin/bash

if [ ! -d prompts ] ; then
  echo "directory not found: prompts"
  exit 1
fi

pushd prompts

for i in prompt*.txt ; do
  echo -n "."
  convert -background white -fill black -font Helvetica -size 512x512 -gravity center label:"$(cat $i)" ${i/.txt/.png}
done
echo

popd
