#!/bin/bash

# This script should be called every minute by a cronjob. If the current
# time is within the day window then it takes a picture, and then resizes it.

OUTDIR="$HOME/sunsetpi/timelapse"

DAY=$(date +"%Y-%m-%d")
TIME=$(date +"%H%M%S")
DATE="${DAY}_${TIME}"

echo "Day: $DAY"
echo "Time: $TIME"
echo "Date: $DATE"

if [ $TIME -gt 210000 ] ; then
  echo "$TIME is after hours"
  exit 0
fi

if [ $TIME -lt  050000 ] ; then
  echo "$TIME is before hours"
  exit 0
fi

originalOutDir="$OUTDIR/$DAY"
resizedOutDir="$OUTDIR/$DAY/resized"
mkdir -p $originalOutDir
mkdir -p $resizedOutDir

originalFilename="$originalOutDir/$DATE.jpg"
resizedFilename="$resizedOutDir/$DATE.jpg"

# actually take the picture. I've found that you need to give the raspberry
# pi camera over 2 seconds for it to get the automatic exposure settings 
# right. So here we use 3 seconds.
raspistill -t 3000 -o $originalFilename

#### This is to resize for 1440p which a raspberry pi 3 b+ is able to
#### enocde to mp4 using ffmpeg but it's occasionally runs out of memory
# convert -resize 2844x -gravity center -crop 2560x1440+0+0 $originalFilename $resizedFilename

#### This is to resize to 1080p which a raspberry pi 3 b+ is able to
#### encode without any problems.
# convert -resize 2074x -gravity center -crop 1920x1080+0+0 $originalFilename $resizedFilename

#### This is to resize to 2160p which must only be used on a high memory pi 4
convert -gravity center -crop 3840x2160+0+0 $originalFilename $resizedFilename
