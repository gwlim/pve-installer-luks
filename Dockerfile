FROM debian:trixie-20260713

ENV PROXMOX_ISO="proxmox-ve_9.2-1.iso"
ENV PROXMOX_ISO_URL="http://download.proxmox.com/iso/"
ENV PROXMOX_ISO_SHA256="4e88fe416df9b527624a175f24c9aa07c714d3332afb1ee3dbf3879573ef2c6c"

RUN apt-get update -y && \
    apt-get install --no-install-recommends -y curl patch squashfs-tools xorriso && \
    apt-get install --no-install-recommends -y --download-only cryptsetup cryptsetup-initramfs keyutils dropbear-initramfs openvswitch-switch uuid-runtime:amd64=2.41-5

RUN curl -L -O --output-dir /tmp/ ${PROXMOX_ISO_URL}${PROXMOX_ISO}

RUN if [ "$(sha256sum /tmp/${PROXMOX_ISO} | awk '{print $1}')" != "${PROXMOX_ISO_SHA256}" ]; then \
        rm -rf /tmp/${PROXMOX_ISO}; \
        echo "PROXMOX ISO sha256 checksum validation failed!" >&2; \
        exit 1; \
    fi

COPY rebuild_iso.sh /sbin/rebuild_iso.sh
COPY patches/ root/patches/
