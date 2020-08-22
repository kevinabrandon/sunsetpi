#!/bin/bash

# a script that gets all the images in the daily crop directory,
# renames them all to be sequential numbers, then encodes a video using
# ffmpeg. Finally it calls the upload script to upload it to youtube.

DAY=$(date +"%Y-%m-%d")

if [ -d "$SUNSETPI_DATA_PATH" ]; then
  cropDir="$SUNSETPI_DATA_PATH/timelapse-crop/$DAY"
  outFile="$SUNSETPI_DATA_PATH/timelapse-mp4s/$DAY.mp4"
else
  cropDir="$SUNSETPI_DATA_NO_MNT/timelapse-crop/$DAY"
  outFile="$SUNSETPI_DATA_NO_MNT/timelapse-mp4s/$DAY.mp4"
fi

cd $cropDir

# rename all the images in the crop dir to be sequential numbers:
a=1
for i in *.jpg; do
  new=$(printf "%04d.jpg" "$a")
  mv -i -- "$i" "$new"
  let a=a+1
done

musicPath=`$SUNSETPI_PATH/daily-music.py path`

# encode the mp4:
ffmpeg -start_number 1 -i %04d.jpg -i "$musicPath" -shortest -c:v libx264 -pix_fmt yuv420p $outFile

# upload the mp4 to youtube:
$SUNSETPI_PATH/upload.sh
