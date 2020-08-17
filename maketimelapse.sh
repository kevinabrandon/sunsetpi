#!/bin/bash

# a script that gets all the images in the daily resized directory,
# renames them all to be sequential numbers, then encodes a video using
# ffmpeg. Finally it calls the upload script to upload it to youtube.

OUTDIR="$HOME/sunsetpi/timelapse"
DAY=$(date +"%Y-%m-%d")
RESIZEDIR="$OUTDIR/$DAY/resized"

cd $RESIZEDIR

# rename all the images in the resized directory to be sequential numbers
a=1
for i in *.jpg; do
  new=$(printf "%04d.jpg" "$a")
  mv -i -- "$i" "$new"
  let a=a+1
done

ffmpeg -start_number 1 -i %04d.jpg -c:v libx264 -pix_fmt yuv420p $DAY.mp4

$HOME/sunsetpi/upload.sh
