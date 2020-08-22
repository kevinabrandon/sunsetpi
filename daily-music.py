#!/usr/bin/python3

#
# a program that gets the daily time-lapse music.
#
# IMPORTANT: Please source the config.sh before calling this program.
#
# USAGE: daily-music.py [path/info]
#  If the argument is path, it will print the full path for the mp3.
#  If the argument is info, it will print the songs title and artist.
#
# Put exactly 31 songs in the $SUNSETPI_PATH/music/ directory.
# Depending on the day of the month it will grab one of the 31 songs.
# It expects the mp3s to be titled "TITLE - ARTIST.mp3"
# All the music I found was from the Youtube Audio Library.
# I filtered the Youtube Audio Library by the following:
#  Genre: Ambient, Cinematic, Country & Folk, and Dance & Electronic.
#  Mood: Bright, Calm, and Inspirational.
#  Attribution not required (although I do attribute it).
#

import os
from datetime import datetime

def getMusic(dt):
	"""
	getMusic takes a datetime and returns the music for that day. It
	returns the full path of the mp3 file, the song title and the artist.
	"""
	projectDir = os.getenv("SUNSETPI_PATH", "/home/pi/sunsetpi")
	musicDir = projectDir+"/music/"

	mp3s=[]
	for file in os.listdir(musicDir):
		if file.endswith(".mp3"):
			mp3s.append(file)

	path = os.path.join(musicDir, mp3s[dt.day])
	title = mp3s[dt.day][:-4].replace("-", "by")

	return path, title

def main():
	import sys

	def usage():
		print("usage: " + sys.argv[0] + " [path/info]")
		print(" If the argument is path, it will print the full path for the mp3.")
		print(" If the argument is info, it will print the songs title and artist.")
		sys.exit(2)

	if len(sys.argv) != 2:
		usage()

	path, info = getMusic(datetime.now())

	if sys.argv[1] == "path":
		print(path)
	elif sys.argv[1] == "info":
		print(info)
	else:
		usage()

if __name__ == '__main__':
	main()
