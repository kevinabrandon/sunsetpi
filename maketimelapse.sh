#!/bin/bash


OUTDIR="$HOME/sunsetpi/timelapse"
DAY=$(date +"%Y-%m-%d")
RESIZEDIR="$OUTDIR/$DAY/resized"

cd $RESIZEDIR
../../../rename.sh

ffmpeg -start_number 1 -i %04d.jpg -c:v libx264 -pix_fmt yuv420p $DAY.mp4

source ../../../../youtube/bin/activate

python upload-video.py \
   --file $DAY.mp4 \
   --title "Daily Timelapse $DAY" \
   --description "Captured, processed, encoded and uploaded automatically from a raspberry pi" \
   --keywords "Raspberry pi, timelapse, sunset, sunsetpi" \
   --privacyStatus public \
   --noauth_local_webserver

