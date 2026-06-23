# OOP Diagram: Deployment Diagram

## Definition
A **Deployment Diagram** is a UML structural diagram that shows the physical deployment of software artifacts (executables, libraries, files) onto hardware nodes (servers, devices, cloud instances). It maps the software components to the infrastructure that runs them.

## Purpose in OOP
- Shows **where** each software component physically runs
- Maps **artifacts** (compiled code, configuration files, databases) to **nodes** (devices, servers)
- Documents the **runtime environment** — operating systems, containers, servers
- Identifies **communication paths** between nodes (protocols, ports)
- Essential for deployment planning, DevOps, and infrastructure documentation

## Key Elements

| Element | Symbol | Description |
|---------|--------|-------------|
| Node | 3D box (cube) | A physical or virtual device (server, phone, cloud instance) |
| Artifact | Rectangle with document icon | A deployable unit (APK, .js file, database, Docker image) |
| Communication Path | Line between nodes | A network connection (HTTP, WebSocket, Wi-Fi) |
| Execution Environment | Nested node | A runtime within a node (Node.js runtime, Flutter engine, browser) |
| Device | Node with <<device>> stereotype | Physical hardware (phone, laptop, server) |
| Deployment Specification | Note attached to artifact | Configuration for deployment (ports, env vars) |

## When to Use
- During **deployment planning** — before setting up infrastructure
- To document the **production environment** for operations teams
- When the system runs on **multiple devices** or across **cloud and local** environments
- In the design document to show examiners how the system is physically deployed

## How It Relates to Other Diagrams
- **Component Diagram** shows software modules; Deployment Diagram shows where they run
- **Network Topology Diagram** shows the network; Deployment Diagram shows software on that network
- **System Architecture Diagram** shows logical layers; Deployment Diagram maps them to physical nodes

## OOP Principles Illustrated
- **Separation of Concerns**: Different components run on different nodes
- **Encapsulation**: Each node encapsulates its execution environment
- **Interface Contracts**: Communication paths define how distributed objects interact
- **Scalability**: Deployment diagrams reveal scaling strategies (horizontal, vertical)

## Drawing Guidelines
1. Identify all physical/virtual nodes (phones, laptops, servers, cloud services)
2. Place software artifacts inside the nodes where they run
3. Label execution environments (Node.js, Flutter, Nginx, Firebase)
4. Draw communication paths with protocol labels
5. Show both development and production environments if they differ
6. Include relevant ports, URLs, or IP addresses

## Common Mistakes
- Confusing deployment with architecture (deployment = physical, architecture = logical)
- Not showing the communication protocol between nodes
- Missing nodes (forgetting the student's device, the database server, etc.)
- Not distinguishing between development and production deployments
- Forgetting cloud services that the system depends on

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
- Visual Paradigm
- Enterprise Architect
- PlantUML
