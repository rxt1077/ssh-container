# ssh-container

This repository contains the config files and scripts needed to set up a
container virtualization environment using
[LXD](https://linuxcontainers.org/lxd/introduction) for use in a networking
lab. A user account (U: container, P: container) is enabled on an SSH
server which starts a new container and runs a shell. When the user exits
the shell the container is deleted. All containers connect to a bridge
linked to port 0 on the server. The server also provides IP addresses and
in the range 10.8.100.80 - 10.8.100.140 and DNS resolution via
[dnsmasq](https://www.thekelleys.org.uk/dnsmasq/doc.html).
