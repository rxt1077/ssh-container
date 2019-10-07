# nftables Lab

## Introduction

The purpose of this lab is to familiarize yourself with using
[nftables](https://wiki.nftables.org/wiki-nftables/index.php/What_is_nftables%3F)
to filter ports in Linux. nftables has superseded ipchains and iptables, but if
you are familiar with either of those utilities nftables is very similar.

## Setup

This lab will require two terminal sessions running on separate containers
within the same network. To set it up:

1. Patch your lab machine's 2nd NIC to the switch above the virtualization
   server on rack 4. This switch is labeled Switch 17. 
2. Open up a terminal on your lab computer and confirm that you can ping
   `10.8.100.30`.
3. Within that same terminal, ssh into the container service on the
   virtualization server with the following command: `ssh
container@10.8.100.30`. If prompted to accept a key, hit yes. When prompted for
a password, type in `container` and hit enter. This will not be echoed on your
display.
4. Repeat Step 3 with another terminal.
5. You should now have shells on two containers each on the same network. Their
   assigned IP addresses are shown in their respective bash prompts.

