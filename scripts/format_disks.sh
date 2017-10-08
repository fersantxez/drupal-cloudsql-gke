#!/bin/bash

#mount and format disks if we're on a GCE VM that has access to them

#make sure we're running as root
if [ "$EUID" -ne 0 ]; then
  echo "** Please run as root. Exiting."
  exit
fi

#make sure we're on a GCE VM
#$ curl metadata.google.internal -i
#HTTP/1.1 200 OK
#or
sudo dmidecode -s bios-vendor | grep -q Google
case $? in
#(0) echo On a GCE instance;;
(0) break;;
(*) echo "Not a GCE instance, please run this on a GCE instance to allow formatting disks";;
esac

#TODO:  make sure that we're on a VM that has access to the disks
#they've been created based on environment variables earlier



#create persistent volumes
#swap out in template for name of service
for (( i=1; i<=$GKE_VOLUME_QTY; i++ )); do
	#create persistent volumes for drupal and apache

	#trick to substitute to variable names
	VOLUME="GKE_VOLUME_"$i
	VOLUME=$(printf '%s\n' "${!VOLUME}")
	SIZE="GKE_VOLUME_SIZE_"$i
	SIZE=$(printf '%s\n' "${!SIZE}")
	DISK=$VOLUME"-disk"
	VOLUME=$VOLUME"-vol"

	#variable indirection
	echo "**DEBUG: variables will be used as: "$VOLUME", "$DISK" and "$SIZE

	#assume the VM has 
	#mount disk


	#format disk


	#umount disk
done