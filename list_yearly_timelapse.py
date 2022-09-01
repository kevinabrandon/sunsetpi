#!/usr/bin/python3

import os
from os import path
from datetime import datetime,timedelta
import solar_times

def parseDateFromFN(filename):
	'''
	Parses and returns a datetime from the given filename.
	Will throw ValueError's when it cannot parse.
	'''
	bname = path.basename(filename)
	dateonly, ext = path.splitext(bname)
	dt = datetime.strptime(dateonly, "%Y-%m-%d_%H%M%S")
	return dt

def getDayPhoto(dir, timeOfDay):
	'''
	Returns a single photo from the daily directory at the given date/time
	'''
	closestFile = ""
	closestTime = 600 # must be within 10 minutes to even be considered
	for f in os.listdir(dir):
		fullname=path.join(dir,f)
		if not path.isfile(fullname):
			continue
		try:
			parsedTime = parseDateFromFN(f)
			deltaTime = abs((timeOfDay - parsedTime).total_seconds())
			if deltaTime < closestTime:
				closestTime = deltaTime
				closestFile = fullname
		except ValueError:
			print(f + " could not parse, ignoring")
			continue
	return closestFile

def getYearlyPhotos(type, delta):
	'''
	Returns a list of photos for the yearly timelapse.
	type must be either "sunrise", "noon", "sunset"
	delta must be a timedelta
	The returned list will be a single photo from each day at the given time for
	that day.
	'''
	datapath = os.getenv("SUNSETPI_DATA_PATH")
	if not datapath:
		print('missing SUNSETPI_DATA_PATH in the env. consider sourcing the config.sh file')
		return []
	if type != "sunrise" and type != "noon" and type != "sunset":
		raise ValueError

	dir = path.join(datapath, 'timelapse-raw')
	photos = []
	for f in os.listdir(dir):
		fulldir = path.join(dir, f)
		if not path.isdir(fulldir):
			continue
		try:
			day = datetime.strptime(f, "%Y-%m-%d")
			rise, noon, set = solar_times.getSolarTimes(day)
			if type == "sunrise":
				timeOfDay = rise + delta
			elif type == "noon":
				timeOfDay = noon + delta
			elif type == "sunset":
				timeOfDay = set + delta
			else:
				return []
			file = getDayPhoto(fulldir, timeOfDay)
			if file:
				photos.append(file)
		except ValueError:
			continue
	photos.sort()
	return photos

def main():
	'''
	usage: list_yearly_timelapse.py [type] [timedelta]
	Gets all the photos for a timelapse at the given time for each day.
	 	where type is "sunrise", "noon", or "sunset"
		and timedelta is in the format HH:MM:SS
	'''
	import sys
	import previous_month

	# default is to run a timelapse at solar noon each day with no delta
	type = "noon"
	delta = timedelta()


	if len(sys.argv) > 2:
		import re
		TIMEDELTA_REGEX = (r'((?P<days>-?\d+)d)?'
			r'((?P<hours>-?\d+)h)?'
			r'((?P<minutes>-?\d+)m)?')
		TIMEDELTA_PATTERN = re.compile(TIMEDELTA_REGEX, re.IGNORECASE)
		def parse_delta(delta):
			""" Parses a human readable timedelta (3d5h19m) into a datetime.timedelta.
			Delta includes:
			* Xd days
			* Xh hours
			* Xm minutes
			Values can be negative following timedelta's rules. Eg: -5h-30m
			"""
			match = TIMEDELTA_PATTERN.match(delta)
			if match:
				parts = {k: int(v) for k, v in match.groupdict().items() if v}
				return timedelta(**parts)
		type = sys.argv[1]
		delta = parse_delta(sys.argv[2])
	photos = getYearlyPhotos(type, delta)
	for photo in photos:
		print(photo)

if __name__ == '__main__':
	main()
