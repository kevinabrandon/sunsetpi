# sunsetpi - A raspberry pi powered daily automated timelapse project

Photos are taken every minute throughout the day. At the end of the day a 4k timelapse is encoded and automatically uploaded to youtube.

Currently running at [Nipomo Sunset Pi](https://www.youtube.com/channel/UCCDV0KIy-Mpz2MSu-qr2w9A) on youtube.

## Future Plans
* Daily backup photos to a network backup.
* Make a multi-year long timelapse of each solar noon, and of each sunset showing how the sun moves across the horizon as the seasons pass. 

## Dependencies
* [imagemagick](https://imagemagick.org/) - for resizing and cropping
* [ffmpeg](https://ffmpeg.org/) - for encoding video
* [Google API Python Client](https://github.com/googleapis/google-api-python-client) - for uploading to youtube

## Reccomended Hardware
1. Raspberry Pi 4 4-8GB (tested with a pi 3 b+ but was unable to encode higher than 1080p)
2. Raspberry Pi HQ Camera
3. Raspberry Pi HQ Camera Lens - Wide Angle
4. Raspberry Pi PoE HAT
5. Outdoor CCTV Camera Housing

## Installation Instructions
1. Setup a raspberry pi (preferably in [headless mode](https://desertbot.io/blog/headless-raspberry-pi-4-ssh-wifi-setup), but not required)
2. Install dependencies:
``` 
sudo apt install ffmpeg
sudo apt install imagemagick
sudo apt install python3-pip
echo 'alias python=python3' >> ~/.bash_aliases
echo 'alias pip=pip3' >> ~/.bash_aliases
source ~/.bashrc
pip install virtualenv
python -m virtualenv sunsetpi
source sunsetpi/bin/activate
python -m pip install google-api-python-client
python -m pip install httplib2
python -m pip install client
python -m pip install oauth2client
```
3. clone this project:
```
cd
git clone https://github.com/kevinabrandon/sunsetpi.git
```
4. setup crontab:
```
cd ~/sunsetpi
crontab -e
```
Add the following lines to the contab: 
```
# trigger the camera every minute
* * * * * /home/pi/sunsetpi/triggercam.sh

### TODO: show how to trigger the video upload
```
5. Setup your project on google api console
```
### TODO: Add detail
```
6. Create oauth2 credentials and put them in ~/sunsetpi/credentials.json
```
### TODO: add detail
```
7. Manually upload a first video so you can allow the project access to your youtube account.
```
### TODO: show how to use the upload script
```
