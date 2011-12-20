#!/system/bin/sh
# 2010-08-05 Firerat, bind mount cache to sd ext partition, and mount mtdblock4 for Clockwork recovery's use
# 2011-12-20 Firerat, get the device block for cache from /proc/mtd instead of assuming it to be mtdblock4
cachemtd=$( awk '/"cache"/ { sub(/mtd/,"/dev/block/mtdblock"); print $1 }' /proc/mtd )
busybox umount /cache
# Bind mount /sd-ext/cache ( or /system/sd/cache ) to /cache
if [ "`busybox egrep -q "sd-ext|/system/sd" /proc/mounts;echo $?`" = "0" ];
then
    sdmount=`busybox egrep "sd-ext|/system/sd" /proc/mounts|busybox awk '{ print $2 }'`
    cacheDir=${sdmount}/cache
else
    cacheDir=/data/cache
fi

if [ ! -d $cacheDir ];
then
    busybox install -m 771 -o 1000 -g 2001 -d $cacheDir
fi
    busybox mount -o bind $cacheDir /cache
if [ ! -d $cacheDir/dalvik-cache ];
then
    busybox install -m 771 -o 1000 -g 1000 -d $cacheDir/dalvik-cache
fi

if [ ! -d /dev/cache ];
then
    busybox install -d /dev/cache
fi

if [ "`grep -q \"/dev/cache\" /proc/mounts;echo $?`" != "0" ];
then
    busybox mount -t yaffs2 -o nosuid,nodev $cachemtd /dev/cache
fi
if [ ! -d /dev/cache/recovery ];
then
    busybox install -m 770 -o 1000 -g 2001 -d /dev/cache/recovery
fi
if [ ! -L $cacheDir/recovery ];
then
    ln -s /dev/cache/recovery $cacheDir/recovery
fi
