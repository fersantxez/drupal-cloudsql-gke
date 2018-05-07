                          #!/bin/bash
# List to format as EXT4 for NFS, SPACE separated as in: 
# "/dev/hda /dev/hdb /dev/hdc"
DISKS="/dev/"${TF_VAR_device_name} 
# just a name for the script below.
FDISK=nfs_fdisk_headless.sh 
# Format disks as EXT4
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
PART_EXISTS=$(/sbin/parted -lm | grep /dev/${var.device_name})
if [[ !  -z  $DPART_EXISTS  ]];then
    #di
./$FDISK #&& rm -f $FDISK                          
                          mkdir -p ${var.export_path}
                          mount -t ext4 \
                           /dev/${var.device_name}1 ${var.export_path}
                          echo "/dev/${var.device_name}1 ${var.export_path} \
                           ext4 defaults 1 1" >> /etc/fstab
			                    mkdir -p ${var.export_path}/${var.vol_1}
                          mkdir -p ${var.export_path}/${var.vol_2}
                          apt-get install -y nfs-kernel-server
                          systemctl status nfs-kernel-server
                          echo "${var.export_path}/${var.vol_1} *(rw,sync,no_subtree_check,no_root_squash)" \
			    >> /etc/exports
                          echo  "${var.export_path}/${var.vol_2} *(rw,sync,no_subtree_check,no_root_squash)" \
			    >> /etc/exports
                          exportfs -a
                          systemctl restart nfs-kernel-server
                          showmount -e