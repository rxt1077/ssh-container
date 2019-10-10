#!/bin/bash

# Runs a temporary container environment for the user

PATH=$PATH:/snap/bin

# Stop and delete our container on EXIT
function cleanup {
	lxc stop "${NAME}"
	lxc delete "${NAME}"
}
trap cleanup EXIT

# Container IDs have to be valid hostnames so we
# preface random characters with "ssh-container"
ID=$( cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1 )
NAME="ssh-container-${ID}"

lxc launch ssh-container "${NAME}" --ephemeral
sleep 2
echo "Waiting for an IP address from the DHCP server..."
lxc exec "${NAME}" -- systemctl start network-online.target
lxc exec "${NAME}" -- /bin/bash
