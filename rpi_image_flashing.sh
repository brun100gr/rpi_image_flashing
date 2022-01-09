#!/bin/bash
RETURN_OK=0
TOO_MANY_USB_DRIVE=1
NO_USB_DRIVE=2

#Colors setting	
RED='\033[0;31m'
GREEN='\33[0;32m'
NC='\033[0m' # No Color

#set -x

read -s -p "Enter Password for sudo: " sudoPW

#Check how many USB Mass Storage are connected
printf "Step 1: check no many than one USB Mass Storage is connected --> "
NUMBER_OF_DEVICES=$(file /sys/block/sd* | grep usb | sed 's|.*/||' | wc -l)
if [ "$NUMBER_OF_DEVICES" -gt 1 ]; then
	printf "${RED}Error: Too many USB drive. Detected $NUMBER_OF_DEVICES.${NC}\n"; exit $TOO_MANY_USB_DRIVE
else
	printf "${GREEN}Passed.${NC}\n"
fi
#Check at least one USB Mass Storage is connected
printf "Step 2: check at least one USB Mass Storage is connected --> "
if [ "$NUMBER_OF_DEVICES" -gt 0 ]; then
	printf "${GREEN}Passed.${NC}\n"
else
	printf "${RED}Error: NO USB drive detected.${NC}\n"; exit $NO_USB_DRIVE
fi

MASS_STORAGE_DRIVE_NAME=$(file /sys/block/sd* | grep usb | sed 's|.*/||')
echo $MASS_STORAGE_DRIVE_NAME

echo $sudoPW | sudo -S umount /dev/$MASS_STORAGE_DRIVE_NAME*

unzip -e $1 -d /tmp/

echo $sudoPW | pv -tpreb /tmp/$(basename $1 .zip).img | sudo -S dd of=/dev/$MASS_STORAGE_DRIVE_NAME bs=4M conv=notrunc,noerror

rm /tmp/$(basename $1 .zip).img

mkdir /tmp/boot_sd

echo $sudoPW | sudo -S mount -o rw /dev/$(echo $MASS_STORAGE_DRIVE_NAME)$(echo '1') /tmp/boot_sd

echo $sudoPW | sudo -S cp /media/sf_shared_folder/RPI/scripts/wpa_supplicant.conf /tmp/boot_sd
echo $sudoPW | sudo -S touch /tmp/boot_sd/ssh

echo $sudoPW | sudo -S umount /tmp/boot_sd

rm -rf /tmp/boot_sd
