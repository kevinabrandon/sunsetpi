#!/usr/bin/python3

import os
from os import path
from datetime import datetime

def parseDateFromFN(filename):
	'''
	Parses and returns a datetime from the given filename.
	Will throw ValueError's when it cannot parse.
	'''
	bname = path.basename(filename)
	dateonly, ext = path.splitext(bname)
	dt = datetime.strptime(dateonly, "%Y-%m-%d_%H%M%S")
	return dt

def dailyRecapPhotos(dir, nPhotosPerDay):
	'''
	Returns the recap photos for the photos in the given directory
	'''
	files = []
	for f in os.listdir(dir):
		fullname=path.join(dir,f)
		if not path.isfile(fullname):
			continue
		try:
			dt = parseDateFromFN(f)
			# ensure that the timestamp is from the first 10 seconds of the minute
			# this removes the images taken on the 15, 30,and 45 seconds of each minute
			if dt.time().second < 10:
				files.append(fullname)
		except ValueError:
			print(f + " could not parse, ignoring")
			continue
	files.sort()
	outputFiles = []
	spacing = int(round(len(files)/nPhotosPerDay))
	i = int(round(spacing/2))
	while i < len(files):
		outputFiles.append(files[i])
		i+=spacing
	return outputFiles

def monthlyRecapPhotos(year, month, nPhotosPerDay):
	'''
	Returns the recap photos for the given month
	'''
	datapath = os.getenv("SUNSETPI_DATA_PATH")

	if not datapath:
		print('missing SUNSETPI_DATA_PATH in the env. consider sourcing the config.sh file')
		return []

	dir = path.join(datapath, 'timelapse-raw')
	dirs = []
	for f in os.listdir(dir):
		fulldir = path.join(dir, f)
		if not path.isdir(fulldir):
			continue
		try:
			dt = datetime.strptime(f, "%Y-%m-%d")
			if dt.year != year:
				continue
			if dt.month != month:
				continue
			dirs.append(fulldir)
		except ValueError:
			continue
	dirs.sort()
	outputfiles = []
	for dir in dirs:
		dailyfiles = dailyRecapPhotos(dir, nPhotosPerDay)
		for f in dailyfiles:
			outputfiles.append(f)

	return outputfiles

def main():
	'''
	usage: monthlyRecapList.py [year] [month] [nPhotosPerDay]

	Lists all the recap photos for the given month of the year.
	When run with no arguments, it uses the previous month with 120 photos per day.
	'''
	import sys
	import previous_month

	# by default run the previous month:
	year, month = previous_month.previousMonth()

	nPhotosPerDay = 120 # 120 photos is 4 seconds at 30 fps or 5 seconds at 24 fps

	if len(sys.argv) > 3:
		year = int(sys.argv[1])
		month = int(sys.argv[2])
		nPhotosPerDay = int(sys.argv[3])

	for f in monthlyRecapPhotos(year, month, nPhotosPerDay):
		 print(f)

if __name__ == '__main__':
	main()
