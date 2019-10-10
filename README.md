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

TODO:

* Write an ansible playbook to set up the server
  * Install lxd, dnsmasq, git, curl
  * Create a user named container
  * Set their shell to the `container_environment.sh` script
  * Update ssh to only accept container connections from local/NJIT networks (see `sshd_config` in configs)
  * Set up dnsmasq to hand out correct IPs (see `dnsmasq.conf` in configs)
  * Set up interfaces for port 4 DHCP
  * Set up DuckDNS cronjob for updating port 4 IP address
