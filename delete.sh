#!/bin/bash

# to delete and reset the set up

ip netns delete client1
ip netns delete client2
ip netns delete client3
ip netns delete client4
ip netns delete client5
ip netns delete client6
ip netns delete router 


ip link delete switch1
ip link delete veth-br-client4
ip link delete veth-br-client5
ip link delete veth-br-client6

ip link delete bri0