#!/usr/bin/python3

# a program that reads in the noaa solar tables to find the
# sunrise/solarnoon/sunset times for a given day.
#
# IMPORTANT: Please source the config.sh before calling this program.
# And install the tables in $SUNSETPI_PATH/solartables/YYYY-TABLE.csv
# Where YYYY is the year (example: 2020), and TABLE is the following:
# "sunrise", "solarnoon", and "sunset"

import os
import csv
from datetime import datetime
import time

def getSolarTimes(dt):
	projectDir = os.getenv("SUNSETPI_PATH", "/home/pi/sunsetpi")
	prefix = projectDir+"/solartables/"+str(dt.year)

	riseData = list(csv.reader(open(prefix+'-sunrise.csv')))
	noonData = list(csv.reader(open(prefix+'-solarnoon.csv')))
	setData  = list(csv.reader(open(prefix+'-sunset.csv')))

	rise = time.strptime(riseData[dt.day][dt.month],"%H:%M")
	noon = time.strptime(noonData[dt.day][dt.month],"%H:%M:%S")
	set  = time.strptime(setData[dt.day][dt.month],"%H:%M")

	riseDT = datetime(dt.year, dt.month, dt.day, rise.tm_hour, rise.tm_min, 0)
	noonDT = datetime(dt.year, dt.month, dt.day, noon.tm_hour, noon.tm_min, noon.tm_sec)
	setDT  = datetime(dt.year, dt.month, dt.day, set.tm_hour,  set.tm_min, 0)

	return riseDT, noonDT, setDT


def main():
	import sys

	rise, noon, set = getSolarTimes(datetime.now())

	if len(sys.argv) == 1:
		print("Sunrise:", rise)
		print("Noon:   ", noon)
		print("Sunset: ", set)
		return
	if sys.argv[1] == "sunrise":
		print("Sunrise:", rise)
	elif sys.argv[1] == "noon":
		print("Noon:   ", noon)
	elif sys.argv[1] == "sunset":
		print("Sunset: ", set)

if __name__ == '__main__':
	main()
