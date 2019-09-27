#!/bin/bash

apt install initramfs-tools

if ! grep overlay /etc/initramfs-tools/modules > /dev/null; then
  echo overlay >> /etc/initramfs-tools/modules
fi

cp overlay /etc/initramfs-tools/scripts

update-initramfs -c -k $(uname -r)
mv /boot/initrd.img-$(uname -r) /boot/initrd7.img

sed -e "s/initramfs.*//" -i /boot/config.txt
echo initramfs initrd7.img >> /boot/config.txt

cp /boot/cmdline.txt /boot/cmdline.txt.orig
sed -e "s/\(.*\)/boot=overlay \1/" -i /boot/cmdline.txt
cp /boot/cmdline.txt /boot/cmdline.txt.overlay

cp overctl /usr/local/sbin

sed -e "s/\(.*\/boot.*\)defaults\(.*\)/\1defaults,ro\2/" -i /etc/fstab
