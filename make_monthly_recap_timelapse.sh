#!/bin/bash

#
# A script that makes a monthly recap video and uploads it to youtube.
#
# Intended to be called as a cron job in the early hours of the first day of each month
#
# usage: make-monthly-recap-timelapse.sh [year] [month]
#   If called with no arguments it makes the most recent complete month
#
# IMPORTANT: be sure to source $SUNSETPI_PATH/config.sh before calling.
#
# 1. Gets a list of all the raw images for time lapse
# 2. Crops and renames the images to have sequential file names.
# 2. Creates a title sequence with the date and music info.
# 3. Create the timelapse sequence.
# 4. Join the title with the timelapse.
# 5. Calculate the length of the timelapse and cut the music to length with
#    a fade out filter.
# 6. Join the music with the video and save it in the output directory.
# 7. Upload the video to YouTube.
#

# get a list of all the images for the timelapse
# if there are 3 arguments assume they're [year] [month] [nPicsPerDay]
# if no arguments assume it's the previous month with 80 pics per day
if [ $# -eq 3 ]; then
  allPics=`$SUNSETPI_PATH/list_monthly_recap.py $1 $2 $3`
  year=$1
  month=$2
else
  allPics=`$SUNSETPI_PATH/list_monthly_recap.py`
  year=`$SUNSETPI_PATH/previous_month.py year`
  month=`$SUNSETPI_PATH/previous_month.py month`
fi

# directories
cropDir="$SUNSETPI_DATA_PATH/timelapse-crop/$year-$month"
tempDir="$SUNSETPI_DATA_PATH/timelapse-temp/$year-$month"
outDir="$SUNSETPI_DATA_PATH/timelapse-mp4s"

mkdir -p "$tempDir"
mkdir -p "$cropDir"
mkdir -p "$outDir"

# the temp and output file names
titleImg="$SUNSETPI_DATA_PATH/title-image.jpg"
titleFile="$tempDir/recap-title.mp4"
timeLapseFile="$tempDir/recap-timelapse.mp4"
fullVidNoAudio="$tempDir/recap-fullVidNoAudio.mp4"
outFile="$outDir/$year-$month-recap.mp4"

# crop the raw files to size and store them in the cropDir
while read -r rawFile ; do
  bname=`basename $rawFile`
  cropFile="$cropDir/$bname"
  convert -gravity center -crop 3840x2160+0+0 $rawFile $cropFile
  echo "resize $rawFile to $cropFile"
done <<< "$allPics"

# rename all the images in the crop dir to be sequential numbers:
cd $cropDir
a=1
for i in *.jpg; do
  new=$(printf "%04d.jpg" "$a")
  mv -i -- "$i" "$new"
  let a=a+1
done

# get the daily music path and info
musicPath=`$SUNSETPI_PATH/monthly-music.py path $month`
musicInfo=`$SUNSETPI_PATH/monthly-music.py info $month`

# make title
frameRate=25
titleSeconds=6
titleFadeDuration=1
titleFadeStart=`expr $titleSeconds - $titleFadeDuration`

size=3840x2160
boxBorder=15
boxAlpha=0.25

titleText="Nipomo Sunset Pi"
titleSize=144

subtitleText="Recap Time-lapse for `date --date="$(printf "%s-%s-01" $year $month)" +"%B %Y"`"
subtitleSize=108

musicTitleText="Music\: $musicInfo"
musicTitleSize=74

fontfile="fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
zoompan="zoompan=x='(iw-iw/zoom)/2':y='(ih-ih/zoom)/2':z='zoom+0.0015':d=$frameRate*$titleSeconds:s=$size"
fade="fade=out:$frameRate*$titleFadeStart:$frameRate*$titleFadeDuration"
title="drawtext=$fontfile: text='$titleText': fontcolor=white: fontsize=$titleSize: box=1: boxcolor=black@$boxAlpha: boxborderw=$boxBorder: x=(w-text_w)/2: y=(h-text_h)/3"
subtitle="drawtext=$fontfile: text='$subtitleText': fontcolor=white: fontsize=$subtitleSize: box=1: boxcolor=black@$boxAlpha: boxborderw=$boxBorder: x=(w-text_w)/2: y=(h-text_h)*2/3"
musicTitle="drawtext=$fontfile: text='$musicTitleText': fontcolor=white: fontsize=$musicTitleSize: box=1: boxcolor=black@$boxAlpha: boxborderw=$boxBorder: x=(w-text_w)/2: y=(h-text_h)*4/5"

echo "Title image: $titleImg"

ffmpeg \
  -i "$titleImg" \
  -filter_complex "$zoompan, $fade, $title, $subtitle, $musicTitle" \
  -c:v libx264 \
  -pix_fmt yuv420p \
  "$titleFile"
echo "$titleFile"

# make timelapse
ffmpeg \
  -start_number 1 \
  -i %04d.jpg \
  -c:v libx264 \
  -pix_fmt yuv420p \
  "$timeLapseFile"
echo "$timeLapseFile"

# join title/timelpase
echo "file '$titleFile'" > vidlist.txt
echo "file '$timeLapseFile'" >> vidlist.txt
ffmpeg \
  -f concat \
  -safe 0 \
  -i vidlist.txt \
  -c copy \
  "$fullVidNoAudio"
echo "$fullVidNoAudio"

# get length of final file
vidLen=`ffprobe \
  -v error \
  -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 \
  $fullVidNoAudio`
echo "$fullVidNoAudio is $vidLen seconds"

# audio fade the music
audioFadeOut=3.0
fadeOutStart=`python3 -c "print($vidLen-$audioFadeOut)"`
echo "Audio fade out begins at $audioFadeOut seconds before the end of the video: $fadeOutStart"
ffmpeg \
  -i "$fullVidNoAudio" \
  -i "$musicPath" \
  -af afade=t=out:st=${fadeOutStart}:d=${audioFadeOut} \
  -c:v copy \
  -map 0:v:0 \
  -map 1:a:0 \
  -shortest \
  "$outFile"
echo "$outFile"

