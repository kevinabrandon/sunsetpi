#!/bin/bash

# This script should be called every minute by a cronjob. If the current
# time is within the day window then it takes a picture, and then resizes it.

DAY=$(date +"%Y-%m-%d")
TIME=$(date +"%H%M%S")
DATE="${DAY}_${TIME}"

if [ -d "$SUNSETPI_DATA_PATH" ]; then
  rawDir="$SUNSETPI_DATA_PATH/timelapse-raw/$DAY"
  cropDir="$SUNSETPI_DATA_PATH/timelapse-crop/$DAY"
else
  rawDir="$SUNSETPI_DATA_NO_MNT/timelapse-raw/$DAY"
  cropDir="$SUNSETPI_DATA_NO_MNT/timelapse-crop/$DAY"
fi

if [ $TIME -gt 210000 ] ; then
  echo "$TIME is after hours"
  exit 0
fi

if [ $TIME -lt  050000 ] ; then
  echo "$TIME is before hours"
  exit 0
fi

mkdir -p $rawDir
mkdir -p $cropDir

rawFile="$rawDir/$DATE.jpg"
cropFile="$cropDir/$DATE.jpg"

# Actually take the picture. I've found that you need to give the raspberry
# pi camera over 2 seconds for it to get the automatic exposure settings
# right. So here we use 3 seconds.
raspistill -t 3000 -o $rawFile -q 94

echo $rawFile

#### This is to resize for 1440p which a raspberry pi 3 b+ is able to
#### enocde to mp4 using ffmpeg but it's occasionally runs out of memory
# convert -resize 2844x -gravity center -crop 2560x1440+0+0 $rawFile $cropFile

#### This is to resize to 1080p which a raspberry pi 3 b+ is able to
#### encode without any problems.
# convert -resize 2074x -gravity center -crop 1920x1080+0+0 $rawFile $cropFile

#### This is to resize to 2160p which must only be used on a high memory pi 4
convert -gravity center -crop 3840x2160+0+0 $rawFile $cropFile

echo $cropFile
