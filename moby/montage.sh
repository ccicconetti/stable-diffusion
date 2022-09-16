#!/bin/bash

mkdir montage 2> /dev/null

for (( i = 0 ; i <= 22 ; i++ )) ; do
  num=$(seq -w $i 100 | head -n 1)
  if [ "$SKIP_MONTAGE" == "" ] ; then
    montage samples/$num*.png -tile 10x montage/$num.jpg
  fi

cat << EOF >> slideshow-1
  <div class="mySlides fade">
    <div class="numbertext">$(( i+1 )) / 23</div>
    <img src="$num.jpg" style="width:100%">
    <div class="text">Page $(( i+1 ))</div>
  </div>
EOF

cat << EOF >> slideshow-2
  <span class="dot" onclick="currentSlide($(( i+1 )))"></span>
EOF

done
