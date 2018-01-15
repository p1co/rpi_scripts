#!/bin/bash

brightness_thresh=23
target_host="someplace.net"
target_port=12345
target_dir="/home/sweet/home"

# Ensure date is accurate to Pacific timezone
DATE=$(TZ=":US/Pacific" date +"%Y-%m-%d_%H%M")
picdir="/home/pi/imgs/"
fn="${picdir}${DATE}".png
echo "Assigning ${fn} as filename.."

# Capture image
echo "Capturing image.."
raspistill -ex auto -o ${fn} -e png -roi 0.4,0.30,0.35,0.35 && sync

# Test for brightness
echo "Testing if image is bright enough.."
brightness=$(convert ${fn} -colorspace hsb -resize 1x1 txt:/dev/stdout | grep hsba\( | sed 's/.* hsb.*,.*,\([0-9.]*\)%.*/\1/')
echo "Brightness level: ${brightness}"
if (( ${brightness} > ${brightness_thresh} )); then
  # Upload newest image to target host
  echo "Uploading image.."
  scp -P ${target_port} ${fn} ${target_host}:${target_dir}&&echo "Upload complete."
else
  echo "Image is too dark, deleting ${fn}.."
  rm ${fn}&&echo "Successfully deleted."
fi
