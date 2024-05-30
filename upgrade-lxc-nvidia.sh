#!/usr/bin/env bash
set -euo pipefail

export $(xargs < .env)

api() {
		curl -sk -H "Authorization: PVEAPIToken=$PVE_TOKEN" $PVE_URL$1
}

VM_IDS=$(api /nodes/prox/lxc | jq '.data[] | select(.tags | length > 0) | select(.tags | contains("nvidia")) | .vmid' -r)
IPS=''
for VMID in $VM_IDS; do
IP=$(api /nodes/prox/lxc/$VMID/interfaces | jq '.data[] | select(.name=="eth0") | .inet' -r | cut -d/ -f1)
IPS="$IPS $IP"
done

if [ -z "$IPS" ]; then
		echo "No LXCs found with tag nvidia, make sure your API token has the right permissions and check curl errors."
		exit 1
fi

SCRIPT=$(cat nvidia-drivers.sh)
xpanes -c "ssh root@{} '$SCRIPT'" $IPS

