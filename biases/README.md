Generate images from all the combinations of prompts x biases

## Prerequisites

- Working conda environment for stable-diffusion scripts called `ldm` (see [README.md](../README.md) instructions)
- Recent [Imagemagick](https://imagemagick.org/)

## Running instructions

From the repo root directory:

```
conda activate ldm
cd biases
./biases.sh
./labels.sh
./montage.sh
```
