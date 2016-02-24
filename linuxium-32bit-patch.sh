#!/bin/sh

# Linuxium's installation script for booting from a 32-bit bootloader

DEFAULT_GATEWAY=`ip r | grep default | cut -d ' ' -f 3`
if ( ! ping -q -w 1 -c 1 "${DEFAULT_GATEWAY}" > /dev/null 2>&1 ); then
	echo "$0: Not connected to internet ... exiting."
	exit
fi

if [ ! -d /target ]; then
	echo "$0: Target file system not mounted ... exiting."
	exit
fi

cat <<+ > /target/etc/apt/sources.list
deb http://mirror-fpt-telecom.fpt.net/ubuntu trusty main restricted universe multiverse
deb-src http://mirror-fpt-telecom.fpt.net/ubuntu trusty main restricted universe multiverse

deb http://mirror-fpt-telecom.fpt.net/ubuntu trusty-updates main restricted universe multiverse
deb-src http://mirror-fpt-telecom.fpt.net/ubuntu trusty-updates main restricted universe multiverse

deb http://mirror-fpt-telecom.fpt.net/ubuntu trusty-backports main restricted universe multiverse
deb-src http://mirror-fpt-telecom.fpt.net/ubuntu trusty-backports main restricted universe multiverse

deb http://mirror-fpt-telecom.fpt.net/ubuntu trusty-security main restricted universe multiverse
deb-src http://mirror-fpt-telecom.fpt.net/ubuntu trusty-security main restricted universe multiverse

deb http://extras.ubuntu.com/ubuntu trusty main
deb-src http://extras.ubuntu.com/ubuntu trusty main
+
mkdir /target
mount /dev/mmcblk0p4 /target 
chroot /target mount -t proc proc /proc 
chroot /target mount -t sysfs sysfs /sys 
mount --bind /dev /target/dev 
mount --bind /run /target/run 
chroot /target apt-get -y purge grub-efi-amd64 grub-efi-amd64-bin grub-efi-amd64-signed 
chroot /target rm -rf /boot/grub/
chroot /target rm -rf /boot/efi/EFI/ubuntu/
chroot /target apt-get update
chroot /target apt-get -y install grub-efi-ia32-bin grub-efi-ia32 grub-common grub2-common
chroot /target mount /dev/mmcblk0p1 /mnt
chroot /target grub-install --target=i386-efi /dev/mmcblk0p1 --efi-directory=/mnt --boot-directory=/boot/ 
chroot /target grub-mkconfig -o /boot/grub/grub.cfg 
chroot /target umount /sys 
chroot /target umount /proc 
umount /target/run 
umount /target/dev 
