#!/bin/bash

audiofile=497047__jiarui-xu__jiarui-xu-piano-concerto-no-1-in-e-minor-iii-presto-con-fuoco.wav

mkdir video 2> /dev/null

pushd video

if [ "$SKIP_SYM_LINKS" == "" ] ; then
  rm -f $(find -type l) 2> /dev/null

  cnt=0
  for i in ../introfinal/intro*.png ; do
    ln -s $i image-$(seq -w $cnt 10000 | head -n 1).png
    cnt=$(( cnt + 1 ))
  done
  for i in ../samples/*.png ; do
    ln -s $i image-$(seq -w $cnt 10000 | head -n 1).png
    cnt=$(( cnt + 1 ))
  done
  for i in ../introfinal/final*.png ; do
    ln -s $i image-$(seq -w $cnt 10000 | head -n 1).png
    cnt=$(( cnt + 1 ))
  done
fi

if [ "$SKIP_ENCODING" == "" ] ; then
  ffmpeg \
    -r 2.41 \
    -f image2 \
    -i image-%05d.png \
    -vcodec libx264 \
    -pix_fmt yuv420p \
    video.mp4
fi

popd

if [ -r "$audiofile" ] ; then
  ffmpeg \
    -i video/video.mp4 \
    -i "$audiofile" \
    -map 0:v \
    -map 1:a \
    -c:v copy \
    -c:a aac \
    final.mp4
else
  echo "Audio file not available, download at https://freesound.org/people/Jiarui_Xu/sounds/497047/"
fi
