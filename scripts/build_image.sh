#!/bin/bash

# Creates and publishes the ssh-container image that is used for creating
# containers when users log in

# NOTE: ip forwarding and nat will need to be set up for the bridge network
# in order for this to work.

set -e

lxc launch ubuntu:18.04 ssh-container
sleep 1
lxc exec ssh-container -- systemctl start network-online.target
lxc exec ssh-container -- apt-get -y remove netcat-openbsd
lxc exec ssh-container -- apt-get -y update
lxc exec ssh-container -- apt-get -y upgrade
lxc exec ssh-container -- apt-get -y autoremove
lxc file push ../configs/container-bashrc ssh-container/root/.bashrc
lxc exec ssh-container -- apt-get -y install netcat-traditional nftables
lxc stop ssh-container
lxc publish ssh-container --alias ssh-container
lxc delete ssh-container
echo "Don't forget to delete the old ssh-container images!"
