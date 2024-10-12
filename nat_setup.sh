#!/bin/bash

# exit witch no zero status
set -e


echo "Creating network spaces ..."

ip netns add client1
ip netns add client2
ip netns add client3
ip netns add router



echo "Creating veth pair for namespaces "

ip link add veth-client1 type veth peer name veth-router1
ip link add veth-client2 type veth peer name veth-router2
ip link add veth-client3 type veth peer name veth-router3


echo "Assigning veth-clients to clients"

ip link set veth-client1 netns client1
ip link set veth-client2 netns client2
ip link set veth-client3 netns client3

echo "Assigning veth-routers to router"

ip link set veth-router1 netns router
ip link set veth-router2 netns router
ip link set veth-router3 netns router


# #-----------------------------------------------------------------------------------------------------------------------#
echo "Connfiguring IP Adderesses ..."

# inside Client1 namespace
ip netns exec client1 ip addr add 192.168.10.2/24 dev veth-client1
ip netns exec client1 ip link set veth-client1 up
ip netns exec client1 ip link set lo up

# inside Client2 namespace
ip netns exec client2 ip addr add 192.168.11.2/24 dev veth-client2
ip netns exec client2 ip link set veth-client2 up
ip netns exec client2 ip link set lo up

# inside Client3 namespace 
ip netns exec client3 ip addr add 192.168.12.2/24 dev veth-client3
ip netns exec client3 ip link set veth-client3 up
ip netns exec client3 ip link set lo up

# inside Router namespace
ip netns exec router ip addr add 192.168.10.1/24 dev veth-router1
ip netns exec router ip addr add 192.168.11.1/24 dev veth-router2
ip netns exec router ip addr add 192.168.12.1/24 dev veth-router3
ip netns exec router ip link set veth-router1 up
ip netns exec router ip link set veth-router2 up
ip netns exec router ip link set veth-router3 up
ip netns exec router ip link set lo up

echo -e 'LINK STATUS OF ROUTER \n'
ip netns exec router ip link show
echo -e '\n'
# #-----------------------------------------------------------------------------------------------------------------------#


echo -e "\n Setting up bridge for public network ..."
# echo -e "\n1"
ip link add name bri0 type bridge 
# echo -e "\n2"
ip addr add 203.0.113.1/24 dev bri0
# echo -e "\n3"
ip link set bri0 up 

# veth creation to connect router to the public internet
ip link add veth-public type veth peer name veth-internet

# Assign veth-public to router
ip link set veth-public netns router

# #  Connect veth-internet to bridge
ip link set veth-internet master bri0
ip link set veth-internet up

# Connect the public network to the router
ip netns exec router ip addr add 203.0.113.2/24 dev veth-public
ip netns exec router ip link set veth-public up

echo -e '\n LINK STATUS OF ROUTER AFTER CONNECTING TO PUBLIC NETWORK \n'
ip netns exec router ip link show
echo -e '\n'

echo -e "Configure router to enable NAT and IP Masquerading...\n"

ip netns exec router sysctl -w net.ipv4.ip_forward=1
ip netns exec router iptables -t nat -A POSTROUTING -o veth-public -j MASQUERADE    


echo -e "\nSetting a default route (gateway) for clients\n"

sudo ip netns exec client1 ip route add default via 192.168.10.1
sudo ip netns exec client2 ip route add default via 192.168.11.1
sudo ip netns exec client3 ip route add default via 192.168.12.1

ip netns exec router ip route add default via 203.0.113.1


#############################################################################################################

echo "Testing connectivity from multiple clients in parallel..."

# Ping and prefix output with client name
sudo ip netns exec client1 ping -c 5 203.0.113.1 | sed 's/^/[Client1] /' &
sudo ip netns exec client2 ping -c 5 203.0.113.1 | sed 's/^/[Client2] /' &
sudo ip netns exec client3 ping -c 5 203.0.113.1 | sed 's/^/[Client3] /' &

wait

echo "Ping tests completed."
#################################################################


# Bonus task 1


echo -e "Hosting a simple webserver using python on client1 "
ip netns exec client1 python3 -m http.server 80 &


echo -e "\nEnabling port forwrding ..."
ip netns exec router iptables -t nat -A PREROUTING -i veth-public -p  tcp --dport 80 -j DNAT --to-destination 192.168.10.2:80

#Forward the traffic via the router
ip netns exec router iptables -A FORWARD -p tcp -d 192.168.10.2 --dport 80 -j ACCEPT &

# # Bonus Task 2

# echo -e "\nAllowing only http and https traffic"
# ip netns exec router iptables -A FORWARD -s 192.168.10.0/24 -p tcp --dport 80 -j ACCEPT
# ip netns exec router iptables -A FORWARD -s 192.168.10.0/24 -p tcp --dport 443 -j ACCEPT
# ip netns exec router iptables -A FORWARD -s 192.168.10.0/24 -j DROP

# Allow incoming HTTP and HTTPS traffic from the public interface (veth-public) to the router
ip netns exec router iptables -A FORWARD -i veth-public -p tcp --dport 80 -j ACCEPT
ip netns exec router iptables -A FORWARD -i veth-public -p tcp --dport 443 -j ACCEPT

# Allow forwarded traffic from client1's subnet to be returned to the public interface
ip netns exec router iptables -A FORWARD -o veth-public -p tcp -s 192.168.10.0/24 --sport 80 -j ACCEPT
ip netns exec router iptables -A FORWARD -o veth-public -p tcp -s 192.168.10.0/24 --sport 443 -j ACCEPT

# Block all other traffic
ip netns exec router iptables -A FORWARD -j DROP


wait

