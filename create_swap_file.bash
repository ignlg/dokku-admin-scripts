#!/usr/bin/env bash

# Set default size
sizeInMegabytes=1024
# Set location
swapFile=/extraswap
# Custom size
if [[ "x$1" != "x" ]]
then
  sizeInMegabytes=$1
fi
# Detect previous swap
foundEntry=$(cat /etc/fstab | grep -i "$swapFile")
if [[ "x$foundEntry" != "x" ]]
then
  # Turn off
  swapoff "$swapFile"
fi
# Create file
echo "SWAP> Creating ${sizeInMegabytes}MB of swap at ${swapFile}"
dd if=/dev/zero of="$swapFile" bs=1M count=${sizeInMegabytes}
# Make it swap
mkswap "$swapFile"
# Detect fstab entry
if [[ "x$foundEntry" == "x" ]]
then
  # Add fstab entry so the swap persists between reboots
  echo "SWAP> Writing /etc/fstab entry"
  echo "$swapFile         none            swap    sw                0       0" >> /etc/fstab
fi
# Turn on swap
swapon "$swapFile"
echo "SWAP> Done."
