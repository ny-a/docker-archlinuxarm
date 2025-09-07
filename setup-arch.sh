#!/bin/sh

set -exuo pipefail

ARMV7_ARCHITECTURE="armv7"

GPG_KEY_ID="77193F152BDBE6A6"
MOUNTPOINT="/mnt"
ARCHITECTURE="$(cat /etc/apk/arch)"

apk update
apk add --no-cache arch-install-scripts

if [ "${ARCHITECTURE}" = "${ARMV7_ARCHITECTURE}" ]; then
  sed -i '/Architecture/s/auto/armv7h/' /etc/pacman.conf
fi

for repo in core extra alarm aur; do
  echo "[$repo]" | tee -a /etc/pacman.conf
  echo "Include = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf
done

mkdir /etc/pacman.d/
echo 'Server = http://mirror.archlinuxarm.org/$arch/$repo' | tee -a /etc/pacman.d/mirrorlist

pacman-key --init
pacman-key -r "${GPG_KEY_ID}"
pacman-key --lsign-key "${GPG_KEY_ID}"

mkdir -p "${MOUNTPOINT}"
pacstrap "${MOUNTPOINT}" base arch-install-scripts $@
rm -r "${MOUNTPOINT}/var/cache/pacman/pkg"

if [ "${ARCHITECTURE}" = "${ARMV7_ARCHITECTURE}" ]; then
  # fix bug in armv7h pacman https://archlinuxarm.org/forum/viewtopic.php?f=57&t=16830
  sed -i '/^CFLAGS=/,/^[[:upper:]]+=/{s/[[:space:]]*-mno-omit-leaf-frame-pointer\b//g}' "${MOUNTPOINT}/etc/makepkg.conf"
fi
