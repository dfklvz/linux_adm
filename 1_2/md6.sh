#!/usr/bin/env bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk

mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}

mdadm --create --verbose /dev/md6 -l 6 -n 5 /dev/sd{b,c,d,e,f}

mkdir -p /etc/mdadm/

echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

parted -s /dev/md6 mklabel gpt
parted /dev/md6 mkpart primary ext4 0% 20%
parted /dev/md6 mkpart primary ext4 20% 40%
parted /dev/md6 mkpart primary ext4 40% 60%
parted /dev/md6 mkpart primary ext4 60% 80%
parted /dev/md6 mkpart primary ext4 80% 100%

mkdir -p /raid/part{1,2,3,4,5}

for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md6p$i; done

for i in $(seq 1 5); do mount /dev/md6p$i /raid/part$i; done

for i in $(seq 1 5); do `echo /dev/md6p$i /raid/part$i ext4 defaults 0 0 >> /etc/fstab`; done
