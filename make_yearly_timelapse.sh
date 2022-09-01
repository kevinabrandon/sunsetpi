#!/bin/bash

#
# A script that makes a one image per day timelapse.
#

# get a list of all the images for the timelapse
# if there are 3 arguments assume they're [year] [month] [nPicsPerDay]
# if no arguments assume it's the previous month with 80 pics per day
timelapseType=$1
timeDelta=$2
allPics=`$SUNSETPI_PATH/list_yearly_timelapse.py $timelapseType $timeDelta`
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Error in list_yearly_timelapse.py"
    exit 1
fi

# directories
cropDir="$SUNSETPI_DATA_PATH/timelapse-crop/$timelapseType$timeDelta"
tempDir="$SUNSETPI_DATA_PATH/timelapse-temp/$timelapseType$timeDelta"
outDir="$SUNSETPI_DATA_PATH/timelapse-mp4s"

mkdir -p "$tempDir"
mkdir -p "$cropDir"
mkdir -p "$outDir"

# the temp and output file names
titleImg="$SUNSETPI_DATA_PATH/title-image.jpg"
titleFile="$tempDir/title.mp4"
timeLapseFile="$tempDir/timelapse.mp4"
fullVidNoAudio="$tempDir/fullVidNoAudio.mp4"
outFile="$outDir/$timelapseType$timeDelta.mp4"

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
musicPath=`$SUNSETPI_PATH/monthly_music.py path 3`
musicInfo=`$SUNSETPI_PATH/monthly_music.py info 3`

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

subtitleText="$timelapseType $timeDelta time-lapse"
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

