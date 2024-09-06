#!/bin/bash

SOURCE=$(pwd)
UNPACK="unpack_root"
RAMDISK="ramdisk_root"

# Exit if $1 were not given
if [[ -z "$1" ]]; then
    echo "Usage: bash unpack.sh <target_image.img>"
    exit 1
fi

# Exit if the supplied value is not .img file.
if [[ "$1" != *.img ]]; then
    echo "Usage: bash unpack.sh <target_image.img>"
    exit 1
fi

# Clean up and create necessary directories
echo "Cleaning up directories before we start..."
sleep 2s
rm -rf $SOURCE/$UNPACK; mkdir -p $SOURCE/$UNPACK
rm -rf $SOURCE/$RAMDISK; mkdir -p $SOURCE/$RAMDISK

# Unpack supplied .img file to $SOURCE/$UNPACK
cd $SOURCE/$UNPACK
echo "Unpacking $1..."
sleep 3s
$SOURCE/magiskboot unpack $SOURCE/$1 2>&1 | tee $SOURCE/$UNPACK/RAMDISK_INFO.txt

# Count CPIO archives.
COUNT_CPIO=$(find "$SOURCE/$UNPACK" -type f -name "*.cpio" | wc -l)

if [[ "$COUNT_CPIO" == "1" ]]; then
    echo "Detected a single ramdisk image!"
    cpio_n="ramdisk.cpio"
fi

if [[ "$COUNT_CPIO" == "3" ]]; then
    echo "Detected a multiple ramdisk images!"
    cpio_n="vendor_ramdisk_recovery.cpio"
fi

# Extracting ramdisk into $SOURCE/$RAMDISK
cd $SOURCE/$RAMDISK
echo "Extracting recovery ramdisk..."
$SOURCE/magiskboot cpio $SOURCE/$UNPACK/$cpio_n extract

