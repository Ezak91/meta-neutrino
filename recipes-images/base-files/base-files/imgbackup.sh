#!/bin/sh

machine="hd51"
hdd_mount="/media/USB"
mountpoint -q /media/HDD && hdd_mount="/media/HDD"
servicedir="$hdd_mount/service"
kernelname="kernel.bin"
rootfsname="neutrino-image-$machine.ext4"
devbase="/dev/mmcblk0p"
dev_display="/dev/dbox/oled0"
part_to_use="$1"
rootdevice="$(sed -e 's/^.*root=//' -e 's/ .*$//' < /proc/cmdline)"

if ! [[ $1 =~ ^[1-4]+$ ]]; then
        if echo "$rootdevice" | grep "3" >> /dev/null; then
                part_to_use="1"
        elif echo "$rootdevice" | grep "5" >> /dev/null; then
                part_to_use="2"
        elif echo "$rootdevice" | grep "7" >> /dev/null; then
                part_to_use="3"
        elif echo "$rootdevice" | grep "9" >> /dev/null; then
                part_to_use="4"
        fi
fi

[  -z "$2" ] && [  -z "$1" ] && [ ! -d "$hdd_mount" ] && { printf '\n\033[31m%s\n' "Give the destination path an argument" && exit 1; }

if [[ "$part_to_use" =~ ^[0-9]+$ ]]; then
        if  [ "$part_to_use" -lt 1 ] || [ $1 -gt 4 ]; then
		{ printf '\n\033[31m%s\n' "Choose a valid partition [1-4]"; exit 1; }
        elif [ "$part_to_use" = 1 ]; then
                part=1; kernel=2; root=3
        elif [ "$part_to_use" = 2 ]; then
                part=2; kernel=4; root=5
        elif [ "$part_to_use" = 3 ]; then
                part=3; kernel=6; root=7
        elif [ "$part_to_use" = 4 ]; then
                part=4; kernel=8; root=9
	fi
fi

function stop_services () {
        pidof smbd >> /dev/null && systemctl stop smb
        pidof nmbd >> /dev/null && systemctl stop nmb
        pidof xupnpd >> /dev/null && systemctl stop xupnpd
        pidof udpxy >> /dev/null && systemctl stop udpxy
        netstat -tl | grep nfs >> /dev/null && systemctl stop nfs-server && systemctl stop nfs-mountd && systemctl stop nfs-statd
        pidof oscam >> /dev/null && systemctl stop oscam
        pidof cccam >> /dev/null && systemctl stop cccam
        pidof gbox >> /dev/null && systemctl stop gbox
        netstat -tl | grep webmin >> /dev/null && systemctl stop webmin
        netstat -tl | grep sunrpc >> /dev/null && systemctl -q stop rpcbind
        netstat -tl | grep ftp >> /dev/null && systemctl stop proftpd
        pidof minidlnad >> /dev/null && systemctl stop minidlna
        pidof automount >> /dev/null && systemctl stop autofs
        pidof ntpdate >> /dev/null && systemctl stop ntpdate
        cd /etc && git status  >> /dev/null && systemctl -q stop etckeeper
        pidof sshd >> /dev/null && systemctl stop sshd.socket
}

function start_services () {
        pidof smbd >> /dev/null || systemctl start smb
        pidof nmbd >> /dev/null || systemctl start nmb
        pidof xupnpd >> /dev/null || systemctl start xupnpd
        pidof udpxy >> /dev/null||  systemctl start udpxy
        netstat -tl | grep nfs >> /dev/null || systemctl start nfs-server && systemctl start nfs-mountd && systemctl start nfs-statd
        pidof oscam >> /dev/null || systemctl start oscam
        netstat -tl | grep webmin >> /dev/null || systemctl start webmin
        netstat -tl | grep sunrpc >> /dev/null || systemctl -q start rpcbind
        netstat -tl | grep ftp >> /dev/null || systemctl start proftpd
        pidof minidlnad >> /dev/null || systemctl start minidlna
        pidof automount >> /dev/null || systemctl start autofs
        pidof ntpdate >> /dev/null || systemctl start ntpdate
        cd /etc && git status  >> /dev/null && systemctl -q start etckeeper
        pidof sshd >> /dev/null || systemctl start sshd.socket
}



clear

[ ! -z "$2" ] && mountpoint -q "$2" && space_available="$(df -Pk $2 | awk 'NR==2 {print $4}')"
[ -z "$2"  ] && [ ! -z "$1" ] && mountpoint -q "$1" && ! [[ "$1" =~ ^[0-9]+$ ]] && space_available="$(df -Pk $1 | awk 'NR==2 {print $4}')"
[ -z "$2"  ] && mountpoint -q "$hdd_mount" && [[ "$1" =~ ^[0-9]+$ ]] && space_available="$(df -Pk $hdd_mount | awk 'NR==2 {print $4}')"
[ -z "$2"  ] && mountpoint -q "$hdd_mount" && [ -z "$1" ] && space_available="$(df -Pk $hdd_mount | awk 'NR==2 {print $4}')"
[ ! -z "$space_available" ] && [ "$space_available" -gt 1048576 ] || { printf '\n\033[31m%s\n' "You need at least 1G of free space on your device" && exit 1; }

printf '\n\033[1m%s\n\033[0m' "Creating backup of partition $part" && echo "Creating backup of partition $part" > "$dev_display"
[ ! -z "$2" ] && destination="$2/backup/partition$part/$machine"
[ -z "$2"  ] && ! [[ "$1" =~ ^[0-9]+$ ]] && destination="$1/backup/partition$part/$machine"
[ -z "$2"  ] && [[ "$1" =~ ^[0-9]+$ ]] && destination="$servicedir/image/backup/partition$part/$machine"
[ -z "$2"  ] && [ -z "$1" ] && destination="$servicedir/image/backup/partition$part/$machine"

[ -d "$destination" ] && rm -rf "$destination"
mkdir -p "$destination"

stop_services

printf '\n\033[33m%s\033[37m%s\n' "Creating kernel backup in $destination/$kernelname " && echo "Creating kernel backup" > "$dev_display"
pv < "$devbase$kernel" > "$destination/$kernelname"

printf '\n\033[33m%s\033[37m%s\n' "Creating rootfs backup in $destination/$rootfsname" && echo "Creating rootfs backup" > "$dev_display"
pv < "$devbase$root" > "$destination/$rootfsname"

printf '\n\033[33m%s\033[37m%s\n' "Checking filesystem in $destination/$rootfsname" && echo "Checking filesystem" > "$dev_display"
tune2fs -i0 -c0 "$destination/$rootfsname" >> /dev/null
e2fsck -y "$destination/$rootfsname" >> /dev/null

[ -f "$servicedir/image/imageversion_partition_$part" ] && cp -f "$servicedir/image/imageversion_partition_$part" "$destination/imageversion"

printf '\n\033[33m%s\033[0m\n' "Compressing $destination/$rootfsname" && echo "Compressing rootfs backup" > "$dev_display"
pv "$destination/$rootfsname" | bzip2 --fast  > "$destination/$rootfsname.bz2" && rm -f "$destination/$rootfsname"

printf '\n\033[1m\033[32m%s\033[0m\n' "Backup successfully completed"  && echo "Backup successfully completed" > "$dev_display"

start_services

sleep 3;
clear