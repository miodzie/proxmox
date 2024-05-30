#!/usr/bin/env bash
set -euo pipefail

# TODO: Add additional steps for hosts/lxcs, ie. NVIDIA Container Toolkit
IS_HOST=${1-:--lxc}
# For latest versions, see https://www.nvidia.com/en-us/drivers/unix/
DRIVER_VERSION="550.78"
FILENAME="NVIDIA-Linux-x86_64-$DRIVER_VERSION.run"

echo "Downloading $FILENAME..."

curl --fail --remote-name --location https://us.download.nvidia.com/XFree86/Linux-x86_64/$DRIVER_VERSION/NVIDIA-Linux-x86_64-$DRIVER_VERSION.run
chmod u+x $FILENAME

./$FILENAME --check

OPTIONS="--silent --allow-installation-with-running-driver"
if [ $IS_HOST == "--host" ]; then
		# For proxmox hosts:
		apt update && apt install -y build-essential proxmox-headers-$(uname -r)
		OPTIONS="${OPTIONS} --disable-nouveau --rebuild-initramfs"
else
		# for LXC containers
		OPTIONS="${OPTIONS} --no-kernel-module"
fi

./$FILENAME $OPTIONS
echo "Success! Rebooting.." && sleep 2
reboot
