# VLANs in Linux

The goal of this lab is to examine how vlan interfaces are created in linux and
see what traffic traverses them.

## Test Network Setup

We will be using two containers each running on the same segment. Open *two*
command windows and inside each one, run the following command: 
`ssh container@virt.duckdns.org`. The password is `container`. You can see the
IP address each container has been given in the prompt:
`root@IP_ADDRESS:~#` where `IP_ADDRESS` is your IP address.

In each container run `ip link show` to show what IP interfaces are available.

In each container run `ip link add link eth0 name eth0.10 type vlan id 10`
This command will create a new vlan tagged interfaces. Run
`ip link set dev eth0.10 up` in each container to bring it up.

Now each container will need to know to route packets over this interface, so
our final step is running `ip route add OTHER_CONTAINER_IP dev eth0.10` in each
container, where OTHER_CONTAINER_IP is the IP of the other container as shown
in the prompt.

## Capturing the VLAN tag of a ping packet

On one container, run `tcpdump -i eth0 -p -n -e -l icmp`. This will start a
packet sniffing program running that will listen for ICMP packets. Despite its
name, tcpdump can also dump information about ethernet frames.

On the other container, run `ping -I eth0.10 OTHER_CONTAINER_IP` where
OTHER_CONTAINER_IP is the IP of the other container as shown in the prompt.
After a few packets, you can use Ctrl-C to stop it. Use the output of tcpdump
on the first container to answer questions.

## Cleanup

When you are all done, you can Ctrl-C out of tcpdump and type `exit` in each
container. Give it a few seconds and it should quit.

## Questions

1. What IP interfaces are available on the container by default?
2. What IP interfaces did you add?
3. What is the ethertype of the ping packets that you sent?
4. What is the VLAN number?
5. If you listened on interface eth0.10 with tcpdump do you think the ethernet
frames would be tagged? (feel free to try it out)
