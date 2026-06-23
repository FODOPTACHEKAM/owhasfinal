# Figure 4.2: Hotspot Network Topology

## Purpose
Shows how devices communicate within the hotspot environment and across deployment modes.

## Diagram Type
**Network Topology Diagram**

## Components

### 1. Lecturer Smartphone / Laptop
- **Role:** Hosts the Wi-Fi hotspot and runs the Node.js server
- **Software:** Flutter app (lecturer mode) + Node.js backend
- **Network:** Creates a Wi-Fi access point (hotspot)
- **IP:** Typically 192.168.x.1 (hotspot gateway)

### 2. Wi-Fi Hotspot
- **Role:** The local area network connecting all devices
- **Type:** Software-based hotspot from lecturer's device
- **Range:** ~10-30 meters (classroom range)
- **Security:** WPA2 password protection
- **SSID:** Configured by lecturer

### 3. Student Smartphones
- **Role:** Connect to hotspot and open browser for attendance
- **Software:** Web browser only (no app installation needed)
- **Network:** Wi-Fi client connected to lecturer's hotspot
- **Access:** Captive portal auto-redirect to registration page

### 4. Student Laptops
- **Role:** Alternative device for students to register attendance
- **Software:** Web browser
- **Network:** Wi-Fi client connected to lecturer's hotspot

### 5. Node.js Server
- **Role:** Backend server processing attendance requests
- **Location:** Running on lecturer's device (localhost:8080)
- **Services:** Express HTTP server, face-api.js, session management
- **Endpoints:** /api/attendance, /api/session, /api/face

### 6. Firebase Cloud (Online/Hybrid Mode)
- **Role:** Cloud backend for data sync and authentication
- **Connection:** Internet (when available)
- **Services:** Firestore, Authentication, Cloud Storage

## Network Topologies by Mode

### Offline Mode (Hotspot)
```
[Lecturer Device]
    |-- Wi-Fi Hotspot (192.168.x.1)
    |-- Node.js Server (localhost:8080)
    |
    +-- [Student Phone 1] (192.168.x.101)
    +-- [Student Phone 2] (192.168.x.102)
    +-- [Student Laptop 1] (192.168.x.103)
    +-- ... up to ~50 devices
```

### Online Mode (Cloud)
```
[Lecturer Device] --Internet--> [Cloud Server (owhas.org)]
                                      |
[Student Phone 1] --Internet--------->|
[Student Phone 2] --Internet--------->|
                                      |
                              [Firebase Cloud]
```

### Institutional Mode (VLAN)
```
[ICTU Server (10.13.14.164)]
    |-- School VLAN Network
    |
    +-- [Lecturer Device] (10.13.14.x)
    +-- [Student Phone 1] (10.13.14.x)
    +-- [Student Phone 2] (10.13.14.x)
    |
    +-- [Firebase Cloud] (internet gateway)
```

## Communication Protocols

| Path | Protocol | Port | Description |
|------|----------|------|-------------|
| Student → Server | HTTP/HTTPS | 8080 | Attendance registration requests |
| Server → Student | HTTP/HTTPS | 8080 | Registration page and responses |
| App → Firebase | HTTPS | 443 | Cloud sync and authentication |
| App → Server | HTTP | 8080 | Dashboard data and session control |
| Captive Portal | HTTP | 80 | Auto-redirect to registration page |

## Captive Portal Flow
1. Student connects to Wi-Fi hotspot
2. Device detects captive portal (no internet)
3. Browser auto-opens registration page
4. Student fills form and submits
5. Server processes and stores attendance

## Drawing Instructions
1. Place lecturer device at the center/top
2. Show Wi-Fi waves emanating from it
3. Arrange student devices around the hotspot
4. Draw connection lines for each device
5. Show the optional internet/cloud path
6. Label protocols and ports on connections
7. Use device icons (laptop, phone, server, cloud)

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
- Cisco Packet Tracer
