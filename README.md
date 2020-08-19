# sunsetpi - A raspberry pi powered, automated timelapse project

Photos are taken regularly throughout the day.  At the end of the day a 4k timelapse is generated and uploaded to youtube.

Currently running at [Nipomo Sunset Pi](https://www.youtube.com/channel/UCCDV0KIy-Mpz2MSu-qr2w9A) on youtube.

## Future Plans
- [x] Add configuration to save data to an external drive.
  - [ ] Daily backup to a network drive.
- [ ] Use localized sunrise/sunset times to start and stop the timelapse.
- [ ] Slow down the timelapse around the sunset or make a seperate sunset-only timelapse without affecting the day-long timelapse.
- [ ] Automatically add title and end screens
  * Perhaps use a photo with a Ken Burns effect with a title and the date in the subtitle.
- [ ] Automatically add royalty free music to the videos.
  * Would be cool to automatically scrape the youtube audio library.
  * More likely I'll download a bunch of music, put it into a folder and cycle through them.
- [ ] Add image stablization to remove wind shaking.
- [ ] Make a multi-year long timelapse of each solar noon, and of each sunset showing how the sun moves across the horizon as the seasons pass.

## Dependencies
* [imagemagick](https://imagemagick.org/) - for resizing and cropping
* [ffmpeg](https://ffmpeg.org/) - for encoding video
* [Google API Python Client](https://github.com/googleapis/google-api-python-client) - for uploading to youtube

## Reccomended Hardware
* [Raspberry Pi 4 4-8GB](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/) (tested with a pi 3 b+ but was unable to encode higher than 1080p)
* [Raspberry Pi HQ Camera](https://www.raspberrypi.org/products/raspberry-pi-high-quality-camera/)
* [Raspberry Pi HQ Camera Lens - Wide Angle](https://www.canakit.com/raspberry-pi-hq-camera-6mm-wide-angle-lens.html)
* [Raspberry Pi PoE HAT](https://www.raspberrypi.org/products/poe-hat/)
* [Outdoor CCTV Camera Housing](https://www.amazon.com/gp/product/B015HSSMSQ/)
* USB External Drive - it generates more than 5 GB of images a day and about 2 TB a year (assuming you want to save the raw images).

## Installation Instructions
1. Setup a raspberry pi (preferably in [headless mode](https://desertbot.io/blog/headless-raspberry-pi-4-ssh-wifi-setup), but not required)
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

# install a virtual environment to install all the youtube specific stuff we need
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
5. setup crontab:
```
cd ~/sunsetpi
crontab -e
```
Add the following lines to the contab: 
```
# trigger the camera every minute:
* * * * * source $HOME/sunsetpi/config.sh; $SUNSETPI_PATH/triggercam.sh

# trigger the daily timelapse creation at 9:15 pm every day:
15 21 * * * source $HOME/sunsetpi/config.sh; $SUNSETPI_PATH/maketimelapse.sh
```
6. Setup your project on google api console
```
### TODO: Add detail
```
7. Create oauth2 credentials and put them in ~/sunsetpi/credentials.json
```
### TODO: add detail
```
8. Manually upload a first video so you can allow the project access to your youtube account.
```
### TODO: show how to use the upload script
```
