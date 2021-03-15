#!/bin/bash

apt install initramfs-tools

if ! grep overlay /etc/initramfs-tools/modules > /dev/null; then
  echo overlay >> /etc/initramfs-tools/modules
fi

cp overlay /etc/initramfs-tools/scripts
mount -o remount,rw /boot

# This is needed for the u-boot
if [ -r /boot/armbianEnv.txt ]; then
  if ! grep boot=overlay /boot/armbianEnv.txt > /dev/null; then
    sed -i '/^extraargs=/{
              s/boot=overlay//g;s/  */ /g;s/=/&boot=overlay /;s/ *$//
	      :1;N;b1
            }
	    $a\
extraargs=boot=overlay' /boot/armbianEnv.txt
  fi
fi

update-initramfs -c -k $(uname -r)

# This is needed for the Raspberry Pi bootloader
if [ -r /boot/config.txt ]; then
  mv /boot/initrd.img-$(uname -r) /boot/initrd7.img

  sed -e "s/initramfs.*//" -i /boot/config.txt
  echo initramfs initrd7.img >> /boot/config.txt

  sed -e 's/.*/ & /;:1;s/ boot=overlay / /g;t1;s/ \+/ /g;s/^ //;s/ $//' /boot/cmdline.txt > /boot/cmdline.txt.orig &&
  sed -e "s/.*/boot=overlay &/" /boot/cmdline.txt.orig >/boot/cmdline.txt.overlay &&
  cp /boot/cmdline.txt.overlay /boot/cmdline.txt
fi

cp overctl /usr/local/sbin

sed -e "/.*\/boot.*ro/b;s/\(.*\/boot.*\)defaults\(.*\)/\1defaults,ro\2/" -i /etc/fstab
