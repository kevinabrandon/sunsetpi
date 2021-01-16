#!/usr/bin/python3

from datetime import datetime
import sys

def previousMonth():
	'''
	returns the year and month of the previous month
	'''
	now = datetime.now()
	year = now.year
	month = now.month - 1 # previous month
	if month == 0:        # check for Jan wrapping to previous Dec
		month = 12
		year -= 1
	return year, month

def main():
	'''
	usage: previous-month.py [option: year/month]
	If called with no options it will print the year and month together.
	If called with an option it will print either the year or month.
	'''
	year, month = previousMonth()
	if len(sys.argv) == 2:
		if sys.argv[1] == "year":
			print(year)
		elif sys.argv[1] == "month":
			print('{0:02d}'.format(month))
		else:
			print(year, '{0:02d}'.format(month))
	else:
		print(year, month)

if __name__ == '__main__':
	main()
