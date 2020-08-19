#!/bin/bash

# config.sh - The main configuration for the sunsetpi project.

# SUNSETPI_PATH is the path to where the project is installed
export SUNSETPI_PATH=$HOME/sunsetpi

# SUNSETPI_DATA is the path to where the timelapse data is stored. Typically
# this should be on an external hard drive. The project will create three
# top level directories here:
#   timelapse-raw, timelapse-resized, and timelapse-mp4s
export SUNSETPI_DATA_PATH=/mnt/sunsetpi

# SUNSETPI_DATA_NO_MNT is used when the SUNSETPI_DATA_PATH is not found (if
# the external drive is not available). Files stored in this directory will be
# cleared daily to prevent filling up the system disk.
export SUNSETPI_DATA_NO_MNT=$HOME

# YOUTUBE_CLIENT_SECRET_PATH is the path to the google api client secret json
# for the youtube upload.
export YOUTUBE_CLIENT_SECRET_PATH=$SUNSETPI_PATH/client_secrets.json
