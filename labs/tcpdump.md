# tcpdump lab

The goal of this lab is to use tcpdump and netcat to capture the TCP three way
handshake. It will require two containers, one of the client and one for the
client and one for the sever.

## Server Set Up

ssh into the container server and make note of your server's IP address in the
prompt. From now on this will be referred to as SERVER_IP_ADDRESS. On the
server, start netcat in the background, listening on port 8888 and writing
output to a temporary file:

```console
root@SERVER_IP_ADDRESS:~# nc -l -p 8888 > output.txt &
[2] 527
```

The `&` at the end of the command tells it to run in the background you will
notice that the shell prints out the PID of the running instance.

tcpdump is a packet sniffer that shows all of the packets seen on the network.
We are going to use a filter to *only* listen for packets that involve port
8888. We are also going to tell tcpdump to not resolve IP addresses or port
numbers (-nn), to print out each line as it arrives (-l), and to not use
relative sequence numbers (-S).

```console
root@SERVER_IP_ADDRESS:~# tcpdump -nn -l -S port 8888
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
```

We now have a server that is listening on port 8888 in the background with
netcat. In the foreground we have tcpdump printing out a summary of all
packets it sees that reference port 8888.

## Client Set Up

ssh into the container server to create a new container for the client.
On the client we will be generating 1024 bytes of random data, connecting to
the server, and sending the bytes. This can all be accomplished with a single
command:

```console
root@CLIENT_IP_ADDRESS:~# dd if=/dev/urandom bs=1024 count=1 | nc SERVER_IP_ADDRESS 8888
```

Once you execute this, you should see the output of tcpdump in the server's
terminal.

## Analysis

Since we are just analyzing the handshake, we only care about the first three
lines of tcpdump output. This output is given as an example, but yours will be
different:

```console
20:22:33.038767 IP 10.8.100.121.36362 > 10.8.100.128.8888: Flags [S], seq 3363474820, win 64240, options [mss 1460,sackOK,TS val 1562512234 ecr 0,nop,wscale 7], length 0
20:22:33.038794 IP 10.8.100.128.8888 > 10.8.100.121.36362: Flags [S.], seq 2201886585, ack 3363474821, win 65160, options [mss 1460,sackOK,TS val 3016227441 ecr 1562512234,nop,wscale 7], length 0
20:22:33.038816 IP 10.8.100.121.36362 > 10.8.100.128.8888: Flags [.], ack 2201886586, win 502, options [nop,nop,TS val 1562512234 ecr 3016227441], length 0
```
tcpdump's basic output uses the following syntax:

```
<timestamp> <protocol> <src ip>.<port> > <dest ip>.<port>: flags, sequence numbers, and options
```

As you can see in the example output included in the lab, the client is
10.8.100.121 and the server is 10.8.100.128. The client is using port 36362 and
the server is using port 8888.

The first packet is a SYN (Flags [S]) with sequence 3363474820 from the client
to the server. This means the client want to initiate a connection.

The second packet is a SYN ACK (Flags [S.]) with sequence 2201886585 and an
acknoledgement of 3363474821 from the server to the client. Notice how the
acknowledgement is 1+ the sequence number of the previous packet. This means
the server got the first packet and is expecting data to continue in this
stream.

The third packet is an ACK (Flags [.]) from the client to the server with an
acknowledgement of 2201886586. Notice how the acknowledgement is 1+ the
sequence number of the previous packet. This means the client got the last
packet and is expecting data to continue in this stream.

At this point a full duplex TCP connection has been established. Feel free to
look at the other packets to see how the sequence and acknowledgement numbers
change.

## Questions

1. What is the port number on the client side of your connection (not 8888)?
2. What was the sequence number your client chose to start the connection?
3. What is the acknowledgement number of the second packet in the three way
handshake?

## Cleanup

Server: Ctrl-C will exit tcpdump and then `exit` will exit the shell.
Client: Ctrl-C will exit netcat and then `exit` will exit the shell.

Please give each container a moment to properly shut down before
closing the terminal window.
