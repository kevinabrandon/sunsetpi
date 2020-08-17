#!/bin/bash

# A simple sscript that finds today's timelapse and uploads it to youtube.

OUTDIR="$HOME/sunsetpi/timelapse"
DAY=$(date +"%Y-%m-%d")
RESIZEDIR="$OUTDIR/$DAY/resized"
cd $RESIZEDIR

source $HOME/youtube/bin/activate

python $HOME/sunsetpi/upload-video.py \
   --file $RESIZEDIR/$DAY.mp4 \
   --title "Daily Timelapse $DAY" \
   --description "Captured, processed, encoded and uploaded automatically from a raspberry pi" \
   --keywords "Raspberry pi, timelapse, sunset, sunsetpi" \
   --privacyStatus public \
   --noauth_local_webserver

deactivate
