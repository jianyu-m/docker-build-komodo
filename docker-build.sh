#!/bin/bash

mkdir -p img
DIR=$(pwd)

cd img

if [ ! -f "z3-4.6.0-x64-ubuntu-16.04.zip" ]
then
    wget https://github.com/Z3Prover/z3/releases/download/z3-4.6.0/z3-4.6.0-x64-ubuntu-16.04.zip; \
fi

if [ ! -f "gcc-linaro-4.9-2016.02-x86_64_arm-eabi.tar.xz" ]; then \ 
    wget http://releases.linaro.org/components/toolchain/binaries/4.9-2016.02/arm-eabi/gcc-linaro-4.9-2016.02-x86_64_arm-eabi.tar.xz; \
fi

if [ ! -f "2016-05-27-raspbian-jessie.zip" ]
then
    wget http://downloads.raspberrypi.org/raspbian/images/raspbian-2016-05-31/2016-05-27-raspbian-jessie.zip; \
fi

if [ ! -f "2016-05-27-raspbian-jessie.img" ]
then
    unzip "2016-05-27-raspbian-jessie.zip"
fi

cd $DIR

mkdir -p mnt/boot
sudo mount -o loop,offset=4194304 img/2016-05-27-raspbian-jessie.img mnt/boot

cp mnt/boot/kernel7.img ./
cp mnt/boot/bcm2709-rpi-2-b.dtb ./

sudo umount mnt/boot

sudo docker build -t="build-komodo" ./

sudo rm build/* -rf
sudo docker run --rm -v `pwd`/build:/opt "build-komodo" bash -c 'cp /komodo/piimage/piimage.img /opt/'

sudo chown -R $USER:$USER build

rm -rf mnt/boot mnt
rm *.img *.dtb



