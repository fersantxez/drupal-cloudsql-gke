#!/bin/bash

mount -t ext4 $DISK"1" $EXPORT_PATH
echo $DISK" "$EXPORT_PATH" ext4 defaults 1 1" >> /etc/fstab
#install NFS
#https://linuxconfig.org/how-to-configure-nfs-on-debian-9-stretch-linux
apt-get install -y nfs-kernel-server
systemctl status nfs-kernel-server
mkdir -p $VOL_1
mkdir -p $VOL_2
echo $VOL_1" *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
echo $VOL_2" *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
exportfs -a
systemctl enable nfs-kernel-server
showmount -e

