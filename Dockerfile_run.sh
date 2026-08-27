#! /bin/bash
mkdir -p iso
sudo docker run --rm --privileged -v $(pwd)/iso:/iso -it proxmox-install-iso:latest bash rebuild_iso.sh
