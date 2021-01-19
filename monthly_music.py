#!/usr/bin/python3

#
# a program that gets the monthly recap time-lapse music.
#
# IMPORTANT: Please source the config.sh before calling this program.
#
# USAGE: monthly_music.py [path/info] {optional month number}
#  If the argument is path, it will print the full path for the mp3.
#  If the argument is info, it will print the songs title and artist.
#
# Put exactly 12 songs in the $SUNSETPI_PATH/monthly-music/ directory.
# Depending on the month of the year it will grab one of the 31 songs.
# It expects the mp3s to be titled "TITLE - ARTIST.mp3"
# All the music I found was from the Youtube Audio Library.
# I filtered the Youtube Audio Library by the following:
#  Genre: Ambient, Cinematic, Country & Folk, and Dance & Electronic.
#  Mood: Bright, Calm, and Inspirational.
#  Attribution not required (although I do attribute it).
#
# It's important that the songs be long enough. The recap videos will
# have a maximum time of 1m45.2s
#

import os
from datetime import datetime

def getMusic(month):
	"""
	getMusic takes a datetime and returns the music for that day. It
	returns the full path of the mp3 file, the song title and the artist.
	"""
	projectDir = os.getenv("SUNSETPI_PATH", "/home/pi/sunsetpi")
	musicDir = projectDir+"/monthly-music/"

	mp3s=[]
	for file in os.listdir(musicDir):
		if file.endswith(".mp3"):
			mp3s.append(file)

	path = os.path.join(musicDir, mp3s[month-1])
	title = mp3s[month-1][:-4].replace("-", "by")

	return path, title

def main():
	import sys

	def usage():
		print("usage: " + sys.argv[0] + " [path/info]  {optional month}")
		print(" If the argument is path, it will print the full path for the mp3.")
		print(" If the argument is info, it will print the songs title and artist.")
		sys.exit(2)

	if len(sys.argv) != 2 and len(sys.argv) != 3:
		usage()

	month = datetime.now().month
	if len(sys.argv) == 3:
		month = int(sys.argv[2])

	path, info = getMusic(month)

	if sys.argv[1] == "path":
		print(path)
	elif sys.argv[1] == "info":
		print(info)
	else:
		usage()

if __name__ == '__main__':
	main()
