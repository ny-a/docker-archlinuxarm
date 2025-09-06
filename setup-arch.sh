#!/bin/sh

set -exuo pipefail

GPG_KEY_ID="77193F152BDBE6A6"
MOUNTPOINT="/mnt"
ARCHITECTURE="${1:-\$arch}"
[ $# -gt 0 ] && shift

apk update
apk add --no-cache arch-install-scripts

if [ "$(cat /etc/apk/arch)" = "armv7" ]; then
  sed -i '/Architecture/s/auto/armv7h/' /etc/pacman.conf
fi

for repo in core extra alarm aur; do
  echo "[$repo]" | tee -a /etc/pacman.conf
  echo "Include = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf
done

mkdir /etc/pacman.d/
echo "Server = http://mirror.archlinuxarm.org/${ARCHITECTURE}/\$repo" | tee -a /etc/pacman.d/mirrorlist

pacman-key --init
pacman-key -r "${GPG_KEY_ID}"
pacman-key --lsign-key "${GPG_KEY_ID}"

mkdir -p "${MOUNTPOINT}"
pacstrap "${MOUNTPOINT}" base arch-install-scripts
rm -r "${MOUNTPOINT}/var/cache/pacman/pkg"
