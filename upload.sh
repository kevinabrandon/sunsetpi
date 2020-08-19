#!/bin/bash

# A simple script that finds today's timelapse and uploads it to youtube.

DAY=$(date +"%Y-%m-%d")

if [ -d "$SUNSETPI_DATA_PATH" ]; then
  timelapseFile="$SUNSETPI_DATA_PATH/timelapse-mp4s/$DAY.mp4"
else
  timelapseFile="$SUNSETPI_DATA_NO_MNT/timelapse-mp4s/$DAY.mp4"
fi

source $HOME/youtube/bin/activate

python $SUNSETPI_PATH/upload-video.py \
   --file $timelapseFile \
   --title "Daily Timelapse $DAY" \
   --description "Captured, processed, encoded and uploaded automatically from a raspberry pi" \
   --keywords "Raspberry pi, timelapse, sunset, sunsetpi" \
   --privacyStatus public \
   --noauth_local_webserver

deactivate
