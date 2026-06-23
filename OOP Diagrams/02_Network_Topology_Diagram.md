# OOP Diagram: Network Topology Diagram

## Definition
A **Network Topology Diagram** illustrates the physical or logical arrangement of devices, nodes, and communication links in a networked system. It shows how hardware components (servers, clients, routers, access points) are interconnected and how data travels between them.

## Purpose in OOP
- Maps the **physical infrastructure** on which object-oriented software components are deployed
- Shows **communication protocols** and network paths between distributed objects
- Identifies network constraints that affect object design (latency, bandwidth, offline capability)
- Complements the Deployment Diagram by showing the network layer underneath

## Key Elements

| Element | Symbol | Description |
|---------|--------|-------------|
| Node / Device | Computer/phone icon or rectangle | A physical or virtual device on the network |
| Connection | Line (solid or dashed) | A network link (Wi-Fi, Ethernet, Internet) |
| Network Segment | Cloud or box | A logical grouping (LAN, WAN, VLAN, Internet) |
| Protocol Label | Text on connection | HTTP, HTTPS, WebSocket, TCP/IP, etc. |
| Access Point | Router/AP icon | Wi-Fi hotspot, router, switch |

## When to Use
- When the system involves **multiple devices** communicating over a network
- For **distributed systems** where objects reside on different nodes
- When **offline/online** modes affect system behavior
- To document **deployment prerequisites** (what hardware and networking is needed)

## How It Relates to Other Diagrams
- **Deployment Diagram** shows software artifacts on nodes; Network Topology shows the links between nodes
- **Component Diagram** shows software modules; Network Topology shows where those modules physically reside
- **Sequence Diagram** shows message flow between objects; Network Topology shows the physical path those messages travel

## OOP Principles Illustrated
- **Distribution of Objects**: Objects may reside on different nodes, requiring serialization/deserialization
- **Interface Contracts**: Network boundaries enforce strict API contracts between distributed components
- **Loose Coupling**: Network-separated components must communicate through well-defined interfaces

## Drawing Guidelines
1. Use standard icons for devices (laptop, phone, server, cloud)
2. Label every connection with its protocol and medium (Wi-Fi, Ethernet, cellular)
3. Show network boundaries (LAN bubble, Internet cloud)
4. Indicate direction of data flow where relevant
5. Note IP addresses or port numbers if architecturally significant

## Common Mistakes
- Omitting the network medium (Wi-Fi vs. Ethernet matters for design decisions)
- Not showing all device types that will use the system
- Mixing logical and physical topology without labeling which is which
- Forgetting to show the internet/cloud connection path

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
- Cisco Packet Tracer (for detailed networking)
- Figma (for clean visual diagrams)
