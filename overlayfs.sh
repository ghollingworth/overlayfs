#!/bin/bash

apt install initramfs-tools busybox-static
[ -r /usr/share/initramfs-tools/hooks/zz-busybox-initramfs ] &&
sed 's/^\(BB_BIN=\).*/\1\/usr\/bin\/busybox/' /usr/share/initramfs-tools/hooks/zz-busybox-initramfs >/usr/share/initramfs-tools/hooks/zzz-busybox-initramfs &&
chmod 755 /usr/share/initramfs-tools/hooks/zzz-busybox-initramfs

if ! grep overlay /etc/initramfs-tools/modules > /dev/null; then
  echo overlay >> /etc/initramfs-tools/modules
fi

cp overlay /etc/initramfs-tools/scripts

# Different distributions place the boot files into slightly different
# locations. So, make an effort to automatically locate them.
boot="$(awk '$2 ~ /^\/boot/ { print $2; exit }' /proc/mounts)"
[ -n "${boot}" -a -r "${cfg}/config.txt" ] || cfg="/boot"
cfg="$(readlink -f "${cfg}/config.txt" 2>/dev/null)"
cfg="$(dirname "${cfg:-/boot/config.txt}")"

mount -o remount,rw "${boot}"

# This is needed for the u-boot
if [ -r "${cfg}/armbianEnv.txt" ]; then
  if ! grep boot=overlay "${cfg}/armbianEnv.txt" > /dev/null; then
    sed -i '/^extraargs=/{
              s/boot=overlay//g;s/  */ /g;s/=/&boot=overlay /;s/ *$//
	      :1;N;b1
            }
	    $a\
extraargs=boot=overlay' "${cfg}/armbianEnv.txt"
  fi
fi

update-initramfs -c -k $(uname -r)

# This is needed for the Raspberry Pi bootloader.
if [ -r "${cfg}/config.txt" ]; then
# mv "${cfg}/initrd.img-$(uname -r)" "${cfg}/initrd7.img"
# sed -e "s/initramfs.*//" -i "${cfg}/config.txt"
# echo initramfs initrd7.img >> "${cfg}/config.txt"

  sed -e 's/.*/ & /;:1;s/ boot=overlay / /g;t1;s/ \+/ /g;s/^ //;s/ $//' "${cfg}/cmdline.txt" > "${cfg}/cmdline.txt.orig" &&
  sed -e "s/.*/boot=overlay &/" "${cfg}/cmdline.txt.orig" >"${cfg}/cmdline.txt.overlay" &&
  cp "${cfg}/cmdline.txt.overlay" "${cfg}/cmdline.txt"
fi

cp overctl /usr/local/sbin

sed -e "/.*\/boot.*ro/b;s/\(.*\/boot.*\)defaults\(.*\)/\1defaults,ro\2/" -i /etc/fstab
