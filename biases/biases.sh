#!/bin/bash

mkdir prompts 2> /dev/null

i=0
while read bias ; do
  while read type ; do
    prompt="$type $bias"
    echo $prompt > prompts/prompt-$(seq -w $i 1000 | head -n 1).txt
    python ../scripts/txt2img.py --plms --prompt "$prompt" --skip_grid --n_iter 4 --n_samples 3 --outdir .
    i=$((i+1))
  done < types.txt
done < biases.txt
