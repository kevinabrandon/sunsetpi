#!/bin/bash

#
# triggercam.sh - triggers the raspberry pi camera if the current time is
# within the day window.
#
# Intended to be installed as a cron job every minute or even multiple times
# a minute.
#
# IMPORTANT: Please source the config.sh file before runing.
#
# USAGE: triggercam.sh [optional sleep seconds]
#  If called with the optional sleep seconds it first sleeps the given
#  number of seconds. Also, if called with the optional sleep seconds
#  it will only trigger the camera if it is within +/- one hour of sunset.
#
# Install as crontab:
#
# # First once a minute without arguments
# * * * * * . $HOME/sunsetpi/config.sh; $SUNSETPI_PATH/triggercam.sh
#
# # Next once a minute with arguments of 15, 30 and 45 seconds
# * * * * * . $HOME/sunsetpi/config.sh; $SUNSETPI_PATH/triggercam.sh 15
# * * * * * . $HOME/sunsetpi/config.sh; $SUNSETPI_PATH/triggercam.sh 30
# * * * * * . $HOME/sunsetpi/config.sh; $SUNSETPI_PATH/triggercam.sh 45
#
# # This will create a timelapse where one photo is taken every minute
# # throughout the day window, but when +/- an hour of sunset it will
# # take a photo every 15 seconds - effectively slowing the timelapse
# # down by a factor of four.
#

if [ $# -ne 0 ] ; then
  sleep $1
fi

DAY=$(date +"%Y-%m-%d")
TIME=$(date +"%H%M%S")
DATE="${DAY}_${TIME}"

# Normally we will save the data in the SUNSETPI_DATA_PATH, but since it's
# an external drive we first check that it is connected. If it is not
# connected then we save to the system disk.
if [ -d "$SUNSETPI_DATA_PATH" ]; then
  rawDir="$SUNSETPI_DATA_PATH/timelapse-raw/$DAY"
  cropDir="$SUNSETPI_DATA_PATH/timelapse-crop/$DAY"
else
  rawDir="$SUNSETPI_DATA_NO_MNT/timelapse-raw/$DAY"
  cropDir="$SUNSETPI_DATA_NO_MNT/timelapse-crop/$DAY"
fi

# get the sunrise and sunset times from the python script and parse out the
# output to get the times without the colons
sunriseTime=`$SUNSETPI_PATH/solar_times.py sunrise | \
  awk {'print $NF'} | \
  awk -F ':' {'print $1 $2 $3'}`

sunsetTime=`$SUNSETPI_PATH/solar_times.py sunset | \
  awk {'print $NF'} | \
  awk -F ':' {'print $1 $2 $3'}`

# get the hours before and after sunrise and sunset
hourBeforeSunrise=`expr $sunriseTime - 10000`
hourBeforeSunset=`expr $sunsetTime - 10000`
hourAfterSunset=`expr $sunsetTime + 10000`

echo "                DAY: $DAY"
echo "               TIME: $TIME"
echo "               DATE: $DATE"
echo "Hour Before Sunrise: $hourBeforeSunrise"
echo "            Sunrise: $sunriseTime"
echo " Hour Before Sunset: $hourBeforeSunset"
echo "             Sunset: $sunsetTime"
echo "  Hour After Sunset: $hourAfterSunset"

# check that we are inside the daytime window
if [ $TIME -gt $hourAfterSunset ] ; then
  echo "$TIME is after hours ($hourAfterSunset)"
  exit 0
fi

if [ $TIME -lt $hourBeforeSunrise ] ; then
  echo "$TIME is before hours ($hourBeforeSunrise)"
  exit 0
fi

# if we were called with an argument then only trigger the camera if
# we are within an hour of sunset
if [ $# -ne 0 ] && [ $TIME -lt $hourBeforeSunset ] ; then
  echo "Within day window but outside of sunset window"
  echo "$1 $TIME $hourBeforeSunset"
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
