#!/bin/bash

wget https://www.gutenberg.org/files/2701/old/moby10b.txt -O - | tail -n +817 tmp.61189 | head -n -6 > moby10b.txt
