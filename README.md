# sunsetpi - A Raspberry Pi powered, automated time-lapse project

Photos are taken regularly throughout the day.  At the end of the day a 4k time-lapse is generated and uploaded to YouTube.

Currently running at [Nipomo Sunset Pi](https://www.youtube.com/channel/UCCDV0KIy-Mpz2MSu-qr2w9A) on YouTube.

## Future Plans
- [x] Add configuration to save data to an external drive.
  - [ ] Daily backup to a network drive.
- [x] Use localized sunrise/sunset times to start and stop the time-lapse.
- [x] Slow down the time-lapse around the sunset.
  - [ ] Make a separate sunset-only time-lapse without affecting the day-long time-lapse.
- [x] Automatically add title ~~and end~~ screens
  * Uses a photo with a Ken Burns effect with the date and music information in the subtitle.
  - [ ] Make the title photo a picture of the daily sunset.
- [ ] Make the YouTube thumbnail be about 15 minutes before sunset.
- [x] Automatically add royalty free music to the videos.
  * ~~Would be cool to automatically scrape the YouTube audio library.~~
  * More likely I'll download a bunch of music, put it into a folder and cycle through them. **(this is what I did)**
- [ ] Add image stabilization to remove wind shaking.
- [x] Make long term time-lapses of solar noon, and of each sunset showing how the sun moves across the horizon as the seasons pass.
  - [x] Automatically make a monthly time-lapse.
  - [x] Make a yearly time-lapse.
  - [x] Make multi-year time-lapses.
- [ ] Automatically maintain monthly playlists on YouTube (August 2020, September 2020, etc.).
- [ ] Make the latest video always the featured video on the channel.

## Dependencies
* [imagemagick](https://imagemagick.org/) - for resizing and cropping
* [ffmpeg](https://ffmpeg.org/) - for encoding video
* [Google API Python Client](https://github.com/googleapis/google-api-python-client) - for uploading to YouTube

## Recommended Hardware
* [Raspberry Pi 4 4-8GB](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/) (tested with a pi 3 b+ but was unable to encode higher than 1080p)
* [Raspberry Pi HQ Camera](https://www.raspberrypi.org/products/raspberry-pi-high-quality-camera/)
* [Raspberry Pi HQ Camera Lens - Wide Angle](https://www.canakit.com/raspberry-pi-hq-camera-6mm-wide-angle-lens.html)
* [Raspberry Pi PoE HAT](https://www.raspberrypi.org/products/poe-hat/)
* [Outdoor CCTV Camera Housing](https://www.amazon.com/gp/product/B015HSSMSQ/)
* USB External Drive - it generates more than 5 GB of images a day and about 2 TB a year (assuming you want to save the raw images).

## Installation Instructions
1. Setup a Raspberry Pi (preferably in [headless mode](https://desertbot.io/blog/headless-raspberry-pi-4-ssh-wifi-setup), but not required)
2. Install an external hard drive and edit fstab so that it always mounts to the same location.
    * This may be optional if you don't care to save the raw data.
    * Carefully follow the instructions found [here](https://www.raspberrypi.org/documentation/configuration/external-storage.md).
3. Install dependencies:
``` 
sudo apt install ffmpeg
sudo apt install imagemagick
sudo apt install python3-pip

# I like to have an alias that forces the python3 and pip3... so that's what I do:
echo 'alias python=python3' >> ~/.bash_aliases
echo 'alias pip=pip3' >> ~/.bash_aliases
source ~/.bashrc

# install a virtual environment to install all the YouTube specific stuff we need
cd
pip install virtualenv
python -m virtualenv youtube
source youtube/bin/activate
python -m pip install google-api-python-client
python -m pip install oauth2client
deactivate
```
4. clone this project:
```
cd
git clone https://github.com/kevinabrandon/sunsetpi.git
```
5. Download the NOAA Solar Calculations for the year
    * Go to the [NOAA Solar Calculator](https://www.esrl.noaa.gov/gmd/grad/solcalc/) and enter in your gps location
    * Click the "Create Sunrise/Sunset Tables for the Year" button
    * Using the mouse select the text of each table and copy and paste them into a spreadsheet program (I used google sheets).
    * Export each table as a csv file called:
      * YYYY-sunrise.csv 
      * YYYY-sunset.csv
      * YYYY-solarnoon.csv
    * Make the YYYY the current year
    * Save the csv files into ~/sunsetpi/solar-tables/
6. setup crontab:
```
crontab -e
```
Add the following lines to the contab: 
```
# trigger the camera every minute:
* * * * * . $HOME/sunsetpi/config.sh; $SUNSETPI_PATH/trigger_cam.sh
# trigger the camera on the 15, 30 and 45 seconds of each minute for the sunset portion:
* * * * * . $HOME/sunsetpi/config.sh; $SUNSETPI_PATH/trigger_cam.sh 15
* * * * * . $HOME/sunsetpi/config.sh; $SUNSETPI_PATH/trigger_cam.sh 30
* * * * * . $HOME/sunsetpi/config.sh; $SUNSETPI_PATH/trigger_cam.sh 45

# trigger the daily time-lapse creation at 9:15 pm every day:
15 21 * * * . $HOME/sunsetpi/config.sh; $SUNSETPI_PATH/make_daily_timelapse.sh
```
7. Setup your project on Google API Console
8. From the Google API Console create oauth2 credentials and put them in ~/sunsetpi/credentials.json
9. After the first day of photos manually run the make_daily_timelapse.sh so that you are able to follow the youtube authorization instructions in the console.
10. For now on the auth is saved and the make_daily_timelapse.sh can be run via cron each day.
