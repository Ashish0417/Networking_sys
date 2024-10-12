
# Creating a NAT (Network Address Translation)


## Introduction
This project involves setting up a basic NAT (Network Address Translation) configuration using Linux network namespaces and iptables. NAT allows multiple devices on a private network to share a single public IP address to communicate with external networks (like the Internet). The project simulates the configuration of NAT using Linux tools such as `ip netns`, `iptables`, and `veth` (virtual Ethernet interfaces).

## Approch
### 1. Setting Up Network Namespaces
We used ip netns to create isolated network environments representing different entities such as a router, client, and server. Each namespace behaves like an independent network device.

**Router namespace**: Acts as the NAT device that will translate internal IP addresses to the public IP address.

**Client namespaces**: Represent private internal hosts that need access to external networks.


### 2. Connecting the Namespaces
Virtual Ethernet pairs (veth) were used to connect the router to the clients and to the outside network (simulated by another namespace).


### 3. Assigning IP Addresses and Routing
Each namespace was assigned an IP address, and routes were set up for traffic to flow between the clients and the public network via the router.

### 4. Enabling IP Forwarding and NAT
To allow packet forwarding through the router and perform NAT, IP forwarding was enabled, and iptables was configured to implement NAT using masquerading.


### 5. Configuring Firewall Rules
The firewall was configured using iptables to restrict outbound traffic to only HTTP (port 80) and HTTPS (port 443), and all other traffic was blocked.


### 6. Testing the Setup
A simple HTTP server was set up in the client namespace using Python, and external access was tested via the router.


