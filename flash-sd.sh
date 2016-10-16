#!/bin/bash

wd=$(pwd)
ubuntuImageUrl="https://rcn-ee.com/rootfs/2016-10-06/flasher/BBB-eMMC-flasher-ubuntu-16.04.1-console-armhf-2016-10-06-2gb.img.xz"
ubuntuImage="$wd/ubuntu-image.img"

listDevices() {
  fdisk -l | grep "Disk /dev"
}

assertRoot() {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
  fi
}

assertRoot

if [ $# -eq 0 ]; then
  echo "You must supply a device name for the SD card to flash"
  listDevices
  exit 1
fi
device=$1

if [ ! -f $ubuntuImage ]
then
	echo "Ubuntu image not found. Downloading..."
  wget -O $ubuntuImage.xz $ubuntuImageUrl
  unxz $ubuntuImage.xz
fi

echo "Writing $ubuntuImage to $device"
apt-get install pv -y
umount $device
dd if=$ubuntuImage | pv | dd of=$device

echo "Done"
