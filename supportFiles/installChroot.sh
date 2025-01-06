#!/bin/bash
# This shell script is executed inside the chroot
set -e

echo Set hostname
echo "debian-live-nano" > /etc/hostname
# echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Set as non-interactive so apt does not prompt for user input
export DEBIAN_FRONTEND=noninteractive 

echo Install security updates and apt-utils
apt-get update
apt-get -y upgrade

# Run customzations before clean
/bin/bash /customize.sh

echo Install packages
apt-get install -y --no-install-recommends linux-image-amd64 live-boot systemd-sysv systemd-resolved systemd-timesyncd zstd
apt-get install -f -y -t stable zstd
apt-get install -f -y e2fsprogs 

echo Clean apt post-install
apt-get clean

echo Enable systemd-networkd as network manager
systemctl enable systemd-networkd
echo Enable systemd-resolved as dns manager
systemctl enable systemd-resolved
echo Enable systemd-timesyncd
systemctl enable systemd-timesyncd

echo Set root password
echo "root:toor" | chpasswd

echo Remove machine-id
rm /etc/machine-id

echo List installed packages
dpkg-query -W -f='${Package}\t${Version}\t${Installed-Size}\n' | sort -k3 -n | tee /packages.txt
