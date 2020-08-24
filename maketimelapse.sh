#!/bin/bash

#
# A script that makes the daily timelapse video and uploads it to youtube.
#
# Intended to be called by a cron job after the day window.
#
# IMPORTANT: be sure to source $SUNSETPI_PATH/config.sh before calling.
#
# 1. Renames all the images to have sequential file names.
# 2. Creates a title sequence with the date and music info.
# 3. Create the timelapse sequence.
# 4. Join the title with the timelapse.
# 5. Calculate the length of the timelapse and cut the music to length with
#    a fade out filter.
# 6. Join the music with the video and save it in the output directory.
# 7. Upload the video to YouTube.
#

DAY=$(date +"%Y-%m-%d")

# check to see if the external drive is connected
if [ -d "$SUNSETPI_DATA_PATH" ]; then
  cropDir="$SUNSETPI_DATA_PATH/timelapse-crop/$DAY"
  tempDir="$SUNSETPI_DATA_PATH/timelapse-temp/$DAY"
  outDir="$SUNSETPI_DATA_PATH/timelapse-mp4s/"
  titleImg="$SUNSETPI_DATA_PATH/title-image.jpg"
else
  cropDir="$SUNSETPI_DATA_NO_MNT/timelapse-crop/$DAY"
  tempDir="$SUNSETPI_DATA_NO_MNT/timelapse-temp/$DAY"
  outDir="$SUNSETPI_DATA_NO_MNT/timelapse-mp4s/"
  titleImg="$SUNSETPI_DATA_NO_MNT/title-image.jpg"
fi

mkdir -p "$tempDir"
mkdir -p "$outDir"

# the temp and output file names
titleFile="$tempDir/title.mp4"
timeLapseFile="$tempDir/timelapse.mp4"
fullVidNoAudio="$tempDir/fullVidNoAudio.mp4"
outFile="$outDir/$DAY.mp4"

# rename all the images in the crop dir to be sequential numbers:
cd $cropDir
a=1
for i in *.jpg; do
  new=$(printf "%04d.jpg" "$a")
  mv -i -- "$i" "$new"
  let a=a+1
done

# get the daily music path and info
musicPath=`$SUNSETPI_PATH/daily-music.py path`
musicInfo=`$SUNSETPI_PATH/daily-music.py info`

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

subtitleText=`date +"%A, %B %-d, %Y"`
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

# upload the mp4 to youtube:
$SUNSETPI_PATH/upload.sh


