#!/bin/bash

files="intro final"

mkdir introfinal 2> /dev/null

pushd introfinal

for f in $files ; do
  convert -background black -fill yellow -font Helvetica -size 512x512 -gravity center label:"$(cat ../$f.txt)" $f-00.png
  for (( i = 1 ; i < 15 ; i++ )) ; do
    ln -s $f-00.png $f-$(seq -w $i 20 | head -n 1).png 2> /dev/null
  done
done

popd
