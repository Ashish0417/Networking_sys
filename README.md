# Creating a NAT (Network Address Translation)

## Introduction
This project demonstrates the setup of NAT (Network Address Translation) using Linux network namespaces, `iptables`, and `veth` interfaces. NAT allows multiple devices on a private network to share a single public IP address for external communication. The project simulates a NAT environment using various Linux tools.

## Approach
### 1. Setting Up Network Namespaces
We use `ip netns` to create isolated network environments representing different entities:

- **Router namespace**: Acts as the NAT device for translating internal IP addresses to a public IP.
- **Client namespaces**: Represent internal hosts requiring access to external networks.

### 2. Connecting the Namespaces
Virtual Ethernet pairs (`veth`) are used to interconnect the router with the clients and the external network:

- **Router and clients** are connected using virtual `veth` pairs.
- **External connection** is simulated by another namespace.

### 3. Assigning IP Addresses and Routing
Each namespace is assigned an IP address, and routing is configured to ensure traffic flows between clients and the public network via the router.

### 4. Enabling IP Forwarding and NAT
IP forwarding is enabled on the router, and `iptables` is configured to implement NAT using masquerading. This allows traffic from internal networks to be translated to the public IP.

### 5. Configuring Firewall Rules
Firewall rules are configured with `iptables` to restrict outbound traffic, allowing only HTTP (port 80) and HTTPS (port 443) traffic. All other traffic is dropped.

### 6. Testing the Setup
A simple HTTP server was hosted in the client namespace using Python, and external access was tested through the router.

## Bonus Tasks Completed

### 1. Configuring Port Forwarding
As an additional task, we configured port forwarding on the router to forward external traffic to the internal web server hosted on the client.

<!-- - A simple web server (Python<>/Apache)<> was hosted on the client machine inside the LAN. -->
- A simple python web server  was hosted on the client machine inside the LAN.
- Using `iptables`, the router was configured to forward requests from the public IP to the web server running on the internal client.

## Challenges Faced
- **Namespace connectivity**: Ensuring proper routing and connectivity between isolated namespaces was crucial to the success of the project.
- **Firewall restrictions**: Properly configuring iptables rules to allow specific traffic (HTTP/HTTPS) while blocking others was a critical task.

## Instructions to Run the Setup
### Prerequisites
Ensure that your Linux environment has the following tools installed:
- `iproute2`
- `iptables`
- `python3`


### Steps to Run:

1. **Clone or create the script**: Save your configuration script in a file (e.g., `nat_setup.sh`).

2. **Make the script executable**:
   ```bash
   chmod +x nat_setup.sh
   ```
3. **Run the script**:
   ```bash
   sudo ./nat_setup.sh
   ```



