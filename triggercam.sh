#!/bin/bash

OUTDIR="$HOME/sunsetpi/timelapse"

DAY=$(date +"%Y-%m-%d")
TIME=$(date +"%H%M%S")
DATE="${DAY}_${TIME}"
FILENAME="$OUTDIR/$DAY/$DATE.jpg"

echo "Day: $DAY"
echo "Time: $TIME"
echo "Date: $DATE"
echo "Filename: $FILENAME"

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

raspistill -t 3000 -o $originalFilename

#### This is to resize for 1440p which a raspberry pi 3 b+ is able to
#### enocde to mp4 using ffmpeg but it's occasionally runs out of memory
#convert -resize 2844x -gravity center -crop 2560x1440+0+0 $originalFilename $resizedFilename

#### This is to resize to 1080p which a raspberry pi 3 b+ is able to
#### encode without any problems.
#convert -resize 2074x -gravity center -crop 1920x1080+0+0 $originalFilename $resizedFilename

#### This is to resize to 2160p which must only be used on a high memory pi 4
convert -gravity center -crop 3840x2160+0+0 $originalFilename $resizedFilename
