#!/bin/bash

OS_VER=1904A
VERSION=v0_4_2
BUILD_DATE=190417
BUILD_FILE=rootfs

OUTPUT_FILE=$BUILD_FILE-$VERSION-$BUILD_DATE.img
SOURCE_LINK=http://cdimage.ubuntu.com/ubuntu-base/releases/16.04/release
SOURCE_FILE=ubuntu-base-16.04.6-base-arm64.tar.gz
:<<!
echo -e '\033[36m Installing requirements... \033[0m'
sudo apt-get install qemu-user-static

echo -e '\033[36m Preparing base images... \033[0m'
echo -e '\033[36m -- checking file... \033[0m'
if [ ! -e "$SOURCE_FILE" ]; then
  echo -e '\033[36m -- not exist, downloading... \033[0m'
  wget $SOURCE_LINK/$SOURCE_FILE
fi

echo -e '\033[36m -- extracting... \033[0m'
if [ -d "image" ]; then
  rm -r image
fi
mkdir image
sudo tar -zxvf $SOURCE_FILE -C image

##### build rootfs

echo -e '\033[36m Building rootfs... \033[0m'
sudo cp -b /etc/resolv.conf            image/etc/resolv.conf
sudo cp /usr/bin/qemu-aarch64-static   image/usr/bin

echo -e '\033[36m -- patching components... \033[0m'
sudo cp -r src/components              image/components
sudo sed -i 's/OS-VER/'${OS_VER}'/g'   image/components/init.sh

#sudo cp src/build_rootfs.sh            image/
sudo cp -r src/*                          image/
echo -e '\033[31m -- [!] please run build_rootfs.sh after chroot \033[0m'
sudo chroot image

echo -e '\033[36m -- clean build script... \033[0m'
rm image/build_rootfs.sh

#####
!
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
#rm -rf image
#rm -rf rootfs

echo -e '\033[32m Done! \033[0m'
!
