#!/bin/bash

# this script is intended to be used after simply running raspistill in
# timelapse mode. It crops all the images in the directory to be 2160p
# and saves them in the ./crop directory. It is NOT used in the daily
# timelapse.

mkdir -p crop

# rename all the images in the resized directory to be sequential numbers
for file in *.jpg; do
  convert -gravity center -crop 3840x2160+0+0 $file crop/$file
done
