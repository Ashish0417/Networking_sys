#!/bin/bash

set -e

#added extra task by connecting 3 clinets to a switch and switch to a router

ip netns add client4
ip netns add client5
ip netns add client6

ip link add switch1 type bridge

ip link set switch1 up

ip link add veth-client4 type veth peer name veth-br-client4
ip link add veth-client5 type veth peer name veth-br-client5
ip link add veth-client6 type veth peer name veth-br-client6

ip link set veth-client4 netns client4
ip link set veth-client5 netns client5
ip link set veth-client6 netns client6

ip link set veth-br-client4 master switch1
ip link set veth-br-client5 master switch1
ip link set veth-br-client6 master switch1

ip netns exec client4 ip link set veth-client4 up
ip netns exec client5 ip link set veth-client5 up
ip netns exec client6 ip link set veth-client6 up

ip link set veth-br-client4 up
ip link set veth-br-client5 up
ip link set veth-br-client6 up

ip netns exec client4 ip addr add 192.168.13.2/24 dev veth-client4
ip netns exec client5 ip addr add 192.168.13.3/24 dev veth-client5
ip netns exec client6 ip addr add 192.168.13.4/24 dev veth-client6

ip netns exec client4 ip link set lo up
ip netns exec client5 ip link set lo up
ip netns exec client6 ip link set lo up

ip link add veth-router type veth peer name veth-br-router
ip link set veth-router netns router

ip link set veth-br-router master switch1
ip link set veth-br-router up
ip netns exec router ip link set veth-router up
ip netns exec router ip addr add 192.168.13.1/24 dev veth-router

ip netns exec client4 ip route add default via 192.168.13.1
ip netns exec client5 ip route add default via 192.168.13.1
ip netns exec client6 ip route add default via 192.168.13.1




