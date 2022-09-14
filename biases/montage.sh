#!/bin/bash

# prpduct of --n_iter and --n_samples in biases.sh
numsamples=12

numbiases=$(wc -l biases.txt | cut -f 1 -d ' ')
numtypes==$(wc -l types.txt | cut -f 1 -d ' ')
numprompts=$(( numbiases * numtypes ))

mkdir final 2> /dev/null

cursample=0
for (( p = 0 ; p < $numprompts ; p++ )) ; do
  promptfile=prompts/prompt-$(seq -w $p 1000 | head -n 1).png
  appendlist=$promptfile
  for (( s = 0 ; s < $numsamples ; s++ )) ; do
    samplefile=samples/$(seq -w $cursample 10000 | head -n 1).png
    appendlist="$appendlist $samplefile"
    cursample=$(( cursample + 1 ))
  done
  echo -n "."
  montage -mode concatenate -tile $(( 1 + numsamples ))x $appendlist final/$(seq -w $p 1000 | head -n 1).png
done
echo "done"
