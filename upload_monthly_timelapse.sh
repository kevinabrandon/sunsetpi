#!/bin/bash

# A simple script that finds today's timelapse and uploads it to youtube.

DAY=$(date +"%Y-%m-%d")

if [ -d "$SUNSETPI_DATA_PATH" ]; then
  timelapseFile="$SUNSETPI_DATA_PATH/timelapse-mp4s/$DAY.mp4"
else
  timelapseFile="$SUNSETPI_DATA_NO_MNT/timelapse-mp4s/$DAY.mp4"
fi

sunriseTime=`$SUNSETPI_PATH/solar_times.py sunrise | \
  awk {'print $NF'} | \
  awk -F ':' {'printf "%s:%s", $1, $2'}`

noonTime=`$SUNSETPI_PATH/solar_times.py noon | \
  awk {'print $NF'} | \
  awk -F ':' {'printf "%s:%s", $1, $2'}`

sunsetTime=`$SUNSETPI_PATH/solar_times.py sunset | \
  awk {'print $NF'} | \
  awk -F ':' {'printf "%s:%s", $1, $2'}`

humanReadableDate=`date +"%A, %B %-d, %Y"`
musicInfo=`$SUNSETPI_PATH/daily_music.py info`
desc=$(printf "Daily time-lapse for %s.\nCaptured, processed, encoded, and uploaded automatically from a Raspberry Pi 4 in Nipomo, CA.\nSunrise was at %s, solar noon at %s, and sunset at %s.\nThe time-lapse begins 1 hour before sunrise and ends 1 hour after sunset. Photos are taken once per minute until an hour before sunset, then every 15 seconds until the end. The photos are played back at 25fps.\nMusic: %s from the Youtube Audio Library\nSee https://github.com/kevinabrandon/sunsetpi for implementation details." \
  "$humanReadableDate" $sunriseTime $noonTime $sunsetTime "$musicInfo")

source $HOME/youtube/bin/activate

echo "$timelapseFile"

python $SUNSETPI_PATH/upload_video.py \
   --file "$timelapseFile" \
   --title "Daily Time-Lapse $DAY" \
   --description "$desc" \
   --keywords "Raspberry pi, timelapse, sunset, sunsetpi" \
   --privacyStatus public \
   --noauth_local_webserver

deactivate
