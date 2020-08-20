#!/usr/bin/python

# a program that reads in the noaa solar tables to find the
# sunrise/solarnoon/sunset times for a given day

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

rise, noon, set = getSolarTimes(datetime.now())
print("Todays sunrise: ", rise)
print("Todays noon:    ", noon)
print("Todays sunset:  ", set)
