# OverlayFS based reliable filesystem

This script is used to convert a Raspberry Pi Raspbian based filesystem to use overlayFS based on the work from:

https://yagrebu.net/unix/rpi-overlay.md

I've put together a simple script that does the steps mentioned in that description such that you can just clone this repo on your Pi
and do `sudo overlayfs.sh`

When you reboot, you'll find that /boot is now mounted read-only and the overlay filesystem is mounted on /
```
mount
...
overlay on / type overlay (rw,noatime,lowerdir=/lower,upperdir=/upper/data,workdir=/upper/work)
...
/dev/mmcblkp1 on /boot type vfat (to,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro)
```

You can see from the file 'overlay' (which is used to create the overlay before the root filesystem is mounted, which is why we need to
create and use an initramfs.) that we mount the root filing system read only on /lower and a tmpfs as /upper/data and /upper/work.

To control the overlayfs then type

```
overctl
Usage: overctl [-h|-r|-s|-t|-w]
		   -h, --help     This message
		   -r, --ro       Set read-only root with overlay fs
		   -s, --status   Show current state
		   -t, --toggle   Toggle between -r and -w
		   -w, --rw       Set read-write root
```

So you can use -r and -w to switch back to read-write mode, update the filesystem and then switch to read only mode again (for updates)
