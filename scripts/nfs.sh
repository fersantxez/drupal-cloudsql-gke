#!/bin/bash

#https://linuxconfig.org/how-to-configure-nfs-on-debian-9-stretch-linux

#create NFS server for the kubernetes cluster

export SUBNET=
export EXPORT_PATH="/var/nfsroot/"
export VOL_1=$EXPORT_PATH"drupal"
export VOL_2=$EXPORT_PATH"apache"
export DISK="/dev/sdb" #extra disk for NFS contents
#create the VM


#create a firewall rule that allows SSH into the VM, in the VPC where it's at


#SSH into the VM

#mount filesystems
# List to format as XFS for ceph, SPACE separated as in: 
# "/dev/hda /dev/hdb /dev/hdc"

# just a name for the script below.
FDISK=fdisk_headless.sh 

# Format disks as XFS
cat > ./$FDISK << EOF
#!/bin/sh
hdd="$DISK"
EOF
cat >> ./$FDISK << 'EOF'
for i in $hdd;do
echo "n
p
1


w
"|fdisk $i;mkfs.ext4 $i;done
EOF
chmod +x ./$FDISK
./$FDISK && rm -f $FDISK

echo 

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

#***ADD A ROUTE in the VPC TO THE NFS SERVER IN THE BACKEND NETWORK

