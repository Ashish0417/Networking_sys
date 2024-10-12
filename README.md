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


- A simple `python` web server  was hosted on the client machine inside the LAN.
- Using `iptables`, the router was configured to forward requests from the public IP to the web server running on the internal client.

### 2. Restricting Outbound Traffic from the LAN (HTTP/HTTPS Only)
To achieve this, we used iptables to filter outbound traffic from the LAN network (192.168.10.0/24) and allowed only connections on ports 80 (HTTP) and 443 (HTTPS). All other outgoing traffic was explicitly blocked.

This setup successfully limited LAN users to web-based connections only, enhancing network security while maintaining essential functionality.

## Challenges Faced
### 1. Accessing the Website Hosted in a Network Namespace:
After setting up multiple network namespaces (client1, client2, client3, and a router) and configuring the network interfaces, I hosted a simple HTTP server using Python on client1. Initially, I configured the necessary `iptables` rules to allow incoming traffic on port 80, facilitating access to the web server from external sources.

However, when I added additional firewall rules to restrict traffic solely to HTTP (port 80) and HTTPS (port 443), I lost access to the web server. Both `curl` and browser requests returned connection errors, indicating that the traffic was being blocked.

#### Problem with the Original Rules:
The broad drop rule (`-j DROP`) at the end of the rule set was too aggressive. It applied to all traffic from the `192.168.10.0/24` subnet that wasn’t explicitly allowed by earlier rules. Even though HTTP and HTTPS traffic were permitted, the broad drop rule inadvertently blocked the connection.

### 2. Solution and Explanation:

#### Allowing Incoming Traffic:
The rules for `veth-public` were modified to explicitly allow incoming HTTP and HTTPS traffic from the public interface to the router:

```bash
ip netns exec router iptables -A FORWARD -i veth-public -p tcp --dport 80 -j ACCEPT
ip netns exec router iptables -A FORWARD -i veth-public -p tcp --dport 443 -j ACCEPT
```
The new rules for veth-public allow incoming HTTP and HTTPS traffic specifically from the public interface to the router. This means that any incoming requests on ports 80 and 443 are explicitly permitted

#### Allowing Returned Traffic:
We allowed the responses from the internal client (where the web server was hosted) to be forwarded back to the public interface:

```bash
ip netns exec router iptables -A FORWARD -o veth-public -p tcp -s 192.168.10.0/24 --sport 80 -j ACCEPT
ip netns exec router iptables -A FORWARD -o veth-public -p tcp -s 192.168.10.0/24 --sport 443 -j ACCEPT

```

The subsequent rules allow the responses from client1 (which hosted the web server) to be sent back through the router to the public interface. This is crucial for enabling the two-way communication necessary for a functioning web server

#### Removing the Broad Drop Rule:
By commenting out the original broad drop rule (-j DROP), you eliminated the risk of inadvertently blocking valid HTTP and HTTPS traffic. The router now allows incoming traffic specifically for these ports and can send responses back to the clients without being blocked.




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

## Single threaded environmenmnt results
 ![Screenshot 2023-08-12 164211](https://github.com/Sanketsb17/Cache-management-using-splay-trees/assets/112432663/15729165-3482-4354-a92f-b15fe4438574)

- 1)Creating Cache of size 3.
- 2)Added 3 key-value pairs in Cache and Printed them all.
- 3)Now after adding 4th entry in Cache least recently added/accessed entry got evicted and 4th entry took it's place.

 ![Screenshot 2023-08-12 164429](https://github.com/Sanketsb17/Cache-management-using-splay-trees/assets/112432663/08df7229-87b3-4607-bd3a-0cb74ecee8b5)

- 4)Now if we add new entry in Cache our second added entry should get evicted since it is least recently added/accessed entry.
- 5)We will access second entry so that it will become recently accessed entry.
- 6)After accessing it Adding new entry in Cache.
- 7)Now printing Cache again.
- 8)least recently accessed entry got evicted and recently accessed entry in still there.



