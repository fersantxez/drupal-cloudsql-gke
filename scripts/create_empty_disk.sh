#!/bin/bash

#get user variables
source ./env.sh

gcloud compute disks create $DISK_NAME --size $DISK_IMAGE_SIZE
gcloud compute images create $DISK_IMAGE_NAME --source-disk $DISK_NAME
