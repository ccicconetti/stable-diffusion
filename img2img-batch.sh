#!/bin/bash

if [ "$PROMPTFILE" == "" ] ; then
  PROMPTFILE=prompts.txt
fi

if [ "$OUTDIR" == "" ] ; then
  OUTDIR=outputs
fi

N_SAMPLES=1
STRENGTHS="0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9"
RUNS=5

if [ "$SRC" == "" ] ; then
  echo "please specify the source image in the SRC environment variable"
  exit 1
fi

if [ ! -r "$SRC" ] ; then
  echo "cannot read file image source file: $SRC"
  exit 1
fi

if [ ! -r "$PROMPTFILE" ] ; then
  echo "cannot read prompt file: $PROMPTFILE"
  exit 1
fi

if [ ! -d $OUTDIR ] ; then
  mkdir -p $OUTDIR 2> /dev/null
fi

while read prompt ; do
  for S in $STRENGTHS ; do
    for (( R = 0 ; R < $RUNS ; R++ )) ; do
      echo "source image '$SRC', strength $S, prompt '$prompt', run $R"
      if [ "$DRY" == "" ] ; then
        python scripts/img2img.py \
          --skip_grid \
          --n_samples $N_SAMPLES \
          --strength $S \
          --init-img "$SRC" \
          --seed $R \
          --outdir $OUTDIR \
          --prompt "$prompt"
      fi
    done
  done
done < $PROMPTFILE
