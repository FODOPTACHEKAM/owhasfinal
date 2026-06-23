# Figure 4.12: Deployment Diagram

## Purpose
Shows the physical deployment of OwHAS software artifacts onto hardware nodes.

## Diagram Type
**UML Deployment Diagram**

## Nodes

### 1. Lecturer Phone / Laptop
- **Type:** <<device>> Physical device
- **OS:** Android / iOS / Windows / macOS
- **Artifacts Deployed:**
  - Flutter Application (APK / IPA / Desktop)
  - Local Database (JSON files)
  - Exported Reports (PDF, Excel)
  - App Configuration (SharedPreferences)
- **Execution Environments:**
  - Flutter Engine (Dart VM)
  - Wi-Fi Hotspot Service (OS-level)
- **Network:** Creates Wi-Fi hotspot (192.168.x.1)

### 2. Lecturer Device (Server Host)
- **Type:** <<device>> Same physical device or separate laptop
- **OS:** Windows / macOS / Linux
- **Artifacts Deployed:**
  - Node.js Runtime (v14+)
  - Express Server (server.js)
  - face-api.js Models (5 neural network models)
  - hotspot.html (Captive portal page)
  - Session Database (JSON)
  - Static Assets (CSS, JS, images)
- **Execution Environments:**
  - Node.js Runtime Environment
  - Express HTTP Server (port 8080)
- **Network:** Listens on 0.0.0.0:8080

### 3. Student Devices
- **Type:** <<device>> Multiple devices (phones, laptops)
- **OS:** Android / iOS / Windows / macOS
- **Artifacts Deployed:**
  - Web Browser (Chrome, Safari, Firefox)
  - No app installation required
- **Execution Environments:**
  - Browser JavaScript Engine
  - Camera API (for face capture)
- **Network:** Connected to lecturer's hotspot as Wi-Fi clients

### 4. Firebase Cloud
- **Type:** <<cloud>> Google Cloud Platform
- **Services Deployed:**
  - Firebase Authentication (email/password)
  - Cloud Firestore (document database)
  - Firebase Storage (file storage)
  - Cloud Functions (optional processing)
- **Execution Environments:**
  - Google Cloud Run
  - Firestore NoSQL Engine
- **Network:** HTTPS (port 443), accessed via internet

### 5. AWS EC2 (Cloud Deployment Mode)
- **Type:** <<server>> Virtual machine
- **OS:** Ubuntu Server
- **Artifacts Deployed:**
  - Nginx (reverse proxy)
  - Node.js Backend (server.js)
  - face-api.js Models
  - SSL Certificate (Let's Encrypt)
- **Execution Environments:**
  - Nginx Web Server
  - Node.js Runtime
  - PM2 Process Manager
- **Network:** Public IP, port 443 (HTTPS), domain: owhas.org

## Communication Paths

| From | To | Protocol | Port | Description |
|------|----|----------|------|-------------|
| Student Device | Lecturer Device (Server) | HTTP | 8080 | Attendance registration (offline) |
| Lecturer App | Lecturer Device (Server) | HTTP | 8080 | Session management |
| Lecturer App | Firebase | HTTPS | 443 | Authentication & cloud sync |
| Student Device | AWS EC2 | HTTPS | 443 | Attendance registration (online) |
| AWS EC2 | Firebase | HTTPS | 443 | Backend-to-cloud communication |
| Lecturer App | AWS EC2 | HTTPS | 443 | Cloud session management |

## Deployment Configurations

### Configuration A: Offline (Hotspot)
```
+---------------------+          +------------------+
| Lecturer Device     |  Wi-Fi   | Student Device 1 |
| +- Flutter App      |←--------→| +- Web Browser   |
| +- Node.js Server   |          +------------------+
| +- Local DB         |  Wi-Fi   +------------------+
| +- face-api Models  |←--------→| Student Device 2 |
| +- Wi-Fi Hotspot    |          | +- Web Browser   |
+---------------------+          +------------------+
```

### Configuration B: Online (Cloud)
```
+------------------+    Internet    +------------------+
| Lecturer Device  |←--------------→| AWS EC2 Server   |
| +- Flutter App   |               | +- Nginx          |
+------------------+               | +- Node.js        |
                                   | +- face-api       |
+------------------+    Internet   | +- SSL Cert       |
| Student Device   |←------------→ +------------------+
| +- Web Browser   |                     |
+------------------+                     | HTTPS
                                         ↓
                                   +------------------+
                                   | Firebase Cloud   |
                                   | +- Auth          |
                                   | +- Firestore     |
                                   | +- Storage       |
                                   +------------------+
```

### Configuration C: Institutional (VLAN)
```
+------------------+    VLAN     +--------------------+
| Lecturer Device  |←----------→| ICTU Server        |
| +- Flutter App   |            | +- Node.js         |
+------------------+            | +- IP: 10.13.14.164|
                                +--------------------+
+------------------+    VLAN          |
| Student Device   |←-----------→    |
| +- Web Browser   |                 ↓
+------------------+           +------------------+
                               | Firebase Cloud   |
                               +------------------+
```

## Drawing Instructions
1. Draw each node as a 3D box (cube) with the <<device>> or <<cloud>> stereotype
2. Place artifacts inside their host nodes
3. Draw communication paths as lines between nodes
4. Label paths with protocol and port
5. Show all three deployment configurations or focus on the primary one
6. Use standard UML deployment notation

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
- Visual Paradigm
- Enterprise Architect
