# Diagram 02: Network Topology & Connectivity

## Purpose
Show how devices and servers connect in different deployment scenarios (offline, online, hybrid).

## Type
**Network Topology Diagram** (Network Architecture)

## Three Scenarios to Show (or create 3 separate sub-diagrams)

### Scenario 1: Offline Mode (Hotspot)
**Components:**
- Lecturer Device (Laptop/Desktop)
  - WiFi Hotspot enabled
  - Node.js Server running (localhost:8080)
  - Local database
- Student Devices (Phones/Tablets)
  - Connected to hotspot
  - Browser accessing hotspot.html
- WiFi Connection (Hotspot network)

**Flow:**
```
Lecturer Device (Server)
    ↓ (WiFi Hotspot)
Student Device 1 → Browser (hotspot.html)
Student Device 2 → Browser (hotspot.html)
Student Device 3 → Browser (hotspot.html)
...
```

### Scenario 2: Online Mode (Cloud)
**Components:**
- Cloud Server (AWS EC2)
  - owhas.org domain
  - Public IP address
  - Firebase backend
- Internet connection
- Student Devices (anywhere)
  - Mobile browser or app
  - Internet required

**Flow:**
```
Lecturer Device
    ↓ (Internet)
Cloud Server (AWS EC2)
    ↓ (Internet)
Student Devices (anywhere)
```

### Scenario 3: Hybrid Mode
**Components:**
- Lecturer Device (Local + Cloud sync)
- Local Network (hotspot)
- Cloud Server (backup/sync)
- Student Devices (can use either path)

**Flow:**
```
Lecturer Device
├─ WiFi Hotspot → Local Students
├─ Internet → Cloud Server
└─ Cloud Server → Remote Students
```

## Network Details to Show
- IP addresses/ranges
- Port numbers
- Protocol types (HTTP/HTTPS, WebSocket)
- Firewall boundaries (if applicable)
- Network security (encryption indicators)
- Auto-detection mechanism (server discovery)

## Key Information to Display
- Device types and roles
- Network names (SSID, domain)
- Connection types (WiFi, Internet)
- Data direction (arrows with labels)
- Optional: latency/bandwidth annotations

## Success Criteria
- Clear distinction between three deployment modes
- All network paths visible
- Shows data flow between all node types
- Indicates which connections require internet

## Tools Suitable For
- Draw.io
- Network diagramming software
- Lucidchart
- Visio

## Related Sections in Final_Doc
- Section 3.2: Network Topology
- Section 9: Deployment Architecture
