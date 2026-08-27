#! /bin/bash
# Run as root

mount -o loop,ro /tmp/${PROXMOX_ISO} /mnt/

cp -a /mnt/. /opt/

unsquashfs /mnt/pve-installer.squashfs

mkdir -p /squashfs-root/opt/

cp /var/cache/apt/archives/*.deb /squashfs-root/tmp/

cp /root/patches/000-no-subscription-repo-pve /squashfs-root/opt/proxmox.sources

cp /root/patches/000-no-subscription-repo-ceph /squashfs-root/opt/ceph.sources

patch -d /squashfs-root/usr/share/perl5/Proxmox/Sys/ -p1 < /root/patches/001-support-mmc.patch
patch -d /squashfs-root/usr/share/perl5/Proxmox/ -p1 < /root/patches/002-configure-repo.patch
patch -d /squashfs-root/usr/sbin/ -p1 < /root/patches/003-add-installer-luks.patch
patch -d /squashfs-root/usr/share/perl5/Proxmox/Sys/ -p1 < /root/patches/003-luks-create.patch
patch -d /squashfs-root/usr/bin/ -p1 < /root/patches/003-encrypt-cb.patch
patch -d /squashfs-root/usr/share/perl5/Proxmox/Install/ -p1 < /root/patches/003-encrypt-config.patch
patch -d /squashfs-root/usr/share/perl5/Proxmox/ -p1 < /root/patches/003-enable-grub-crypto.patch

mksquashfs /squashfs-root/ /tmp/pve-installer.squashfs -comp zstd -Xcompression-level 19

cp /tmp/pve-installer.squashfs /opt/

cp /var/cache/apt/archives/*.deb /opt/proxmox/packages/

dd if=/tmp/${PROXMOX_ISO} bs=512 count=1 of=/root/proxmox.mbr

xorriso -as mkisofs \
     -o /iso/Repacked-${PROXMOX_ISO} \
     -r -V 'PVE' \
     --grub2-mbr /root/proxmox.mbr \
     --protective-msdos-label \
     -efi-boot-part --efi-boot-image \
     -c '/boot/boot.cat' \
     -b '/boot/grub/i386-pc/eltorito.img' \
       -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
     -eltorito-alt-boot \
     -e '/efi.img' -no-emul-boot \
     /opt/

