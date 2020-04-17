# nftables Lab

## Introduction

The purpose of this lab is to familiarize yourself with using
[nftables](https://wiki.nftables.org/wiki-nftables/index.php/What_is_nftables%3F)
to filter ports in Linux. nftables has replaced ipchains and iptables but if
you are familiar with either of those utilities nftables is very similar.

## General Setup

This lab will require two terminal sessions running on separate containers
within the same network. To set it up:

1. Connect to the ssh-container network, this can be done locally (in class)
or remotely (from home):
    * Locally: Patch your lab machine's 2nd NIC to the switch above the
    virtualization server on *Rack 1*. This switch is labeled *Switch 17*.
    Open a terminal on your lab computer and confirm that you can ping
    `10.8.100.30`.
    * Remotely: [Use Cisco Anyconnect Secure Mobility client to connect to the NJIT VPN from home.](https://ist.njit.edu/vpn/)
2. From within terminal or powershell use ssh to connect to the container
service in the lab:
    * Locally: `ssh container@10.8.100.30`
    * Remotely: `ssh container@virt.duckdns.org`
3.  If prompted to accept a key, type `y`. When prompted for a password, type in
`container` and hit enter. This will not be echoed on your display.
4. Repeat Steps 3 and 4 with another terminal / powershell.
5. You should now have two shells on two containers each on the same network.
Their assigned IP addresses are shown in their respective bash prompts.

## Scenario

A server on your network has been compromised with a remote shell running on a
port 8888. You will be using [nmap](https://nmap.org) to scan the server and
confirm that the port is open. You will then use nftables to shut down access
to the port and log access attempts.

## Compromising the Server

Choose one of your terminals to be the compromised server and execute the
following command on it. You only need to type what is *after* the # prompt.
Note the IP_ADDRESS that is shown in your prompt. From now on this will be
referred to as the compromised server's ip address.

```console
root@IP_ADDRESS:~# nc -l -p 8888 -e /bin/sh &
```

This runs a shell in the background that listens on port 8888.

## Scanning / Accessing the Compromised Server

In the other terminal run the following command. Substitute the compromised
server's ip address for COMPROMISED_SERVERS_IP.

```console
root@IP_ADDRESS:~# nmap COMPROMISED_SERVERS_IP
```
nmap is a security scanner that will default to scanning common ports on a
host. Examine the output of the command. Which ports are open?

Lets now confirm that we can access a remote shell on the compromised server
using netcat. Enter the following command:

```console
root@IP_ADDRESS:~# nc COMPROMISED_SERVERS_IP 8888
```

You will not see a prompt, but you should now be connected to a root shell. Try
typing `ps ax` to see the currently running processes. Now type `whoami` to
confirm that you are root. Finally type `exit` to leave.

Netcat is a good tool to be familiar with as it is the "Swiss army knife" of
TCP/UDP connections. If you need to test a connection, chances are you can do
it with netcat.

## Securing the Compromised Server

Unfortunately the `exit` command caused our remote shell to shut down. Creating
a persistent remote shell is out of the scope of this lab, so instead we will
simply restart it. On the compromised server execute the following command:

```console
root@IP_ADDRESS:~# nc -l -p 8888 -e /bin/sh &
```

Now we will become more acquainted with using netfilter's tables. On the
compromised server, run `nft list tables`. This command will show you all of the
tables`. On your container there should only be one, *inet filter*. This table
filters packets at layer 3 (inet).

Let's examine the *chains* and *rules* in *inet filter*. Run
`nft list table inet filter`. You should see three chains: *input*, *forward*,
and *output*. Each of those chains has a default policy of *accept*.

With nftables you can change how the server receives, forwards, and sends
packets. We are concerned with how the server receives packets, so we will be
adding a rule to the *input* chain. Type in the following command to add a rule
to log and drop all packets sent to port 8888:

```console
nroot@IP_ADDRESS:~# nft add rule inet filter input tcp dport 8888 log group 0 drop
``` 

Before we procede, let's take a moment to understand what each of these
options does:

* *nft* - this is the command we are running
* *add* - this is the action we are taking
* *rule* - we are adding a rule
* *inet filter input* - this rule is being added to the input chain of the
  *inet filter* table
* *tcp dport 8888* - this rule only applies to tcp packets with a destination
  port of 8888
* *log group 0* - log these packets using the nfnetlink_log group (to userspace)
* *drop* - drop these packets to prevent connections

We can view the current state of the *inet filter* table with the following
command:

```console
root@IP_ADDRESS:~# nft list table inet filter
table inet filter {
        chain input {
                type filter hook input priority 0; policy accept;
                tcp dport 8888 log group 0 drop
        }

        chain forward {
                type filter hook forward priority 0; policy accept;
        }

        chain output {
                type filter hook output priority 0; policy accept;
        }
}
```

## Testing the Compromised Server

On the other terminal, run nmap again to scan your server:
 
```console
root@IP_ADDRESS:~# nmap COMPROMISED_SERVERS_IP
```

You should see that port 8888 is now filtered. nmap scans ports using SYN
packets to initiate a connection. Our rule prevents the server from responding
at all to the SYN packet, but typically a closed port would respond with an
RST. Because of this, nmap can detect that the port has been explicitely
filtered.

Now run the netcat command again to see if you can connect:

```console
root@IP_ADDRESS:~# nc COMPROMISED_SERVERS_IP 8888
```

This command should time out eventually, demonstrating that a connection can no
longer be made.

## Reading the Logs

On the compromised server we are going to examine the log file to see if we can
see the traffic from our test. Run the following command:

```console
root@IP_ADDRESS:~# cat /var/log/ulog/syslogemu.log
Oct  8 22:10:19 ssh-container-kld16d0k  IN=eth0 OUT= MAC=00:16:3e:b3:b2:53:00:16:3e:d8:ea:49:08:00 SRC=10.8.100.136 DST=10.8.100.95 LEN=60 TOS=00 PREC=0x00 TTL=64 ID=30956 DF PROTO=TCP SPT=60268 DPT=8888 SEQ=701156108 ACK=0 WINDOW=64240 SYN URGP=0 MARK=0
Oct  8 22:10:53 ssh-container-kld16d0k  IN=eth0 OUT= MAC=00:16:3e:b3:b2:53:00:16:3e:d8:ea:49:08:00 SRC=10.8.100.136 DST=10.8.100.95 LEN=60 TOS=00 PREC=0x00 TTL=64 ID=30957 DF PROTO=TCP SPT=60268 DPT=8888 SEQ=701156108 ACK=0 WINDOW=64240 SYN URGP=0 MARK=0
```

As shown above, you should see the date, time, IP, MAC, and other parameters of
any traffic destined for port 8888 on your compromised server. This could be
used to track down who was accessing the shell on your compromised server.

## Clean Up

Type `exit` in both shells. The containers may take a few seconds to shut down,
please let them complete their shutdown procedure.
