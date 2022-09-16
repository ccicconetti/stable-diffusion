# A stable-diffusion movie of Moby Dick

Experiment to create a movie made of AI-generated pictures from a novel.

## Prerequisites

- Working conda environment for stable-diffusion scripts called `ldm` (see [README.md](../README.md) instructions)
- Recent [Imagemagick](https://imagemagick.org/)

## Instructions

First cd into the `moby` directory:

```
cd moby
```

Then download from [the Gutenberg project](https://www.gutenberg.org/) the novel Moby Dick:

```
./download.sh
```

You should have a file called `moby10b.txt` in the directory.

Now run stable diffusion (it took about 8 hours on an NVIDIA T4):

```
python mobysplit.py < moby10b.txt
```

Optionally, you can dowload the music from [freesound.org](https://freesound.org/people/Jiarui_Xu/sounds/497047/) (requires free registration).

To create the movie, with intro and final scenese:

```
./introfinal.sh
./video.sh
```

If everything goes all right, the final movie will be in `movie.mp4`.

To create miniatures (100 images each) in a `montage` directory, run:

```
./montage.sh
```