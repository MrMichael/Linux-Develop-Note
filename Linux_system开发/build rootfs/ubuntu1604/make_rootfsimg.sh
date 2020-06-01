#!/bin/bash

VERSION=v0_10_1
BUILD_DATE=191017
BUILD_FILE=rootfs

OUTPUT_FILE=$BUILD_FILE-$VERSION-$BUILD_DATE.img
echo -e '\033[36m Creating filesystem... \033[0m'
echo -e '\033[36m -- making .img file... \033[0m'
dd if=/dev/zero of=$OUTPUT_FILE bs=1M count=5096

echo -e '\033[36m -- formating filesystem... \033[0m'
sudo mkfs.ext4 $OUTPUT_FILE


if [ -d "rootfs" ]; then
  rm -r rootfs
fi
mkdir  rootfs
sudo mount $OUTPUT_FILE rootfs/

echo -e '\033[36m -- copying rootfs... \033[0m'
sudo cp -rfp image/*  rootfs/
sudo umount rootfs/


echo -e '\033[36m Final checking... \033[0m'
e2fsck -p -f $OUTPUT_FILE
resize2fs -M $OUTPUT_FILE

echo -e '\033[36m Cleaning files... \033[0m'
rm -rf rootfs

echo -e '\033[32m Done! \033[0m'

