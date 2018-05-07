#!/bin/bash
# List to format as EXT4 for NFS, SPACE separated as in: 
# "/dev/hda /dev/hdb /dev/hdc"
DISKS="/dev/"${device_name}

# Create a script to partition disks
FDISK=nfs_fdisk_headless.sh  #just a name for the script below.
# script to format disks as EXT4
cat > ./$FDISK << EOF
#!/bin/sh
hdd="$DISKS"
EOF
cat >> ./$FDISK << 'EOF'
for i in $hdd;do
echo "n
p
1


w
"|fdisk $i;mkfs.ext4 -F $i;done
EOF
chmod +x ./$FDISK

#run only if the disk does not have any existing partitions
export UNPARTITIONED=$(/sbin/parted -lm 2>&1 \
    | grep 'unrecognised' \
    | grep ${device_name} \
    )
    
if [[ !  -z  $UNPARTITIONED  ]];then
    #disk is not partitioned yet
    echo "**DEBUG: disk "${DISKS}" is not partitioned. Partitioning as ext4"
    ./$FDISK #&& rm -f $FDISK
else
    echo "**DEBUG: disk "${DISKS}" exists and is partitioned. Reusing it."
fi

#mount and use
mkdir -p ${export_path}
mount -t ext4 \
/dev/${device_name}1 ${export_path}
echo "/dev/${device_name}1 ${export_path} ext4 defaults 1 1" >> /etc/fstab
mkdir -p ${export_path}/${vol_1}
mkdir -p ${export_path}/${vol_2}
apt-get install -y nfs-kernel-server
systemctl status nfs-kernel-server
echo "${export_path}/${vol_1} *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
echo  "${export_path}/${vol_2} *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
exportfs -a
showmount -e