# Diagram 19: Offline Deployment Architecture

## Purpose
Show the complete technical setup for offline deployment using lecturer's laptop as hotspot and local server.

## Type
**Deployment Architecture Diagram**

## Components Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                    OFFLINE DEPLOYMENT                            │
│                  (Self-Contained LAN Setup)                      │
└──────────────────────────────────────────────────────────────────┘
```

## Component 1: Lecturer Device (Windows/Mac/Linux)

### Hardware Requirements
```
Minimum:
  ├─ CPU: Dual-core (2.0+ GHz)
  ├─ RAM: 4GB (8GB recommended)
  ├─ Storage: 500MB free space
  ├─ WiFi: 802.11ac or newer
  └─ Battery: 4+ hours

Recommended:
  ├─ CPU: Quad-core (2.5+ GHz)
  ├─ RAM: 8GB+
  ├─ Storage: 1GB free
  ├─ WiFi: Dual-band (2.4GHz + 5GHz)
  └─ Wired connection: For stability
```

### Software Stack
```
Operating System:
  ├─ Windows: 7/8/10/11
  ├─ macOS: 10.14+
  └─ Linux: Ubuntu 18.04+

Required Software:
  ├─ Node.js v14+ (backend server)
  ├─ SQLite 3 (local database)
  ├─ Python 3.8+ (optional, for utilities)
  ├─ Flutter SDK (for lecturer app)
  └─ Dart SDK (included with Flutter)

Installed Applications:
  ├─ start-server.bat (Windows batch script)
  ├─ start-server.sh (macOS/Linux shell script)
  ├─ OwHAS Flutter app (packaged APK/IPA/EXE)
  └─ Database files (sessions.db, students.db)
```

### WiFi Hotspot Configuration
```
Hotspot Name (SSID): OWHAS-[Lecturer Initials]
  ├─ Example: OWHAS-AK (for Dr. Ahmed Khan)
  ├─ Visibility: Broadcast (visible to students)
  └─ Frequency: Both 2.4GHz and 5GHz if available

Security:
  ├─ Type: WPA2-PSK (WPA2 Personal)
  ├─ Encryption: AES
  ├─ Password: [Random 10+ characters]
  │  └─ Provided to students during class
  │
  ├─ Optional: WPA3 if supported by devices
  └─ Not recommended: Open WiFi (security risk)

Performance:
  ├─ Channel: Auto-select or 1/6/11 (2.4GHz)
  ├─ Channel Width: 20MHz (2.4GHz), 40/80MHz (5GHz)
  ├─ Band Steering: Enabled (auto 2.4/5GHz switching)
  ├─ Guest Network: Optional (if separation needed)
  └─ Max Clients: Depends on hardware (typically 50+)
```

### Port Configuration
```
Local Server Listening:
  ├─ HTTP: http://localhost:8080
  ├─ HTTPS: https://localhost:8443 (self-signed cert)
  ├─ WebSocket: ws://localhost:8080
  ├─ Database: sqlite:///./sessions.db (local file)
  └─ Node.js process: Running on same device

Firewall Settings:
  ├─ Allow: Incoming on port 8080 (HTTP)
  ├─ Allow: Incoming on port 8443 (HTTPS)
  ├─ Block: All other ports (by default)
  └─ WiFi: Shared (students access via hotspot)
```

## Component 2: Local Node.js Server

### Server File Structure
```
project-root/
├── server.js (Main entry point, ~500 lines)
├── package.json (Dependencies: express, sqlite3, etc.)
├── start-server.bat (Windows launcher)
├── start-server.sh (macOS/Linux launcher)
├── routes/
│   ├── sessions.js (POST /api/session/start|end)
│   ├── attendance.js (POST /api/attendance/register)
│   ├── reports.js (POST /api/report/generate)
│   └── health.js (GET /api/health)
├── middleware/
│   ├── auth.js (Token validation)
│   ├── cors.js (Cross-origin requests)
│   └── errorHandler.js (Error logging)
├── public/
│   ├── hotspot.html (Student registration page)
│   ├── face-api.min.js (Face detection library)
│   ├── app.js (Client-side logic)
│   └── styles.css (Styling)
├── database/
│   ├── sessions.db (SQLite database file)
│   └── backup/ (Local backups)
├── certificates/
│   ├── server.cert (Self-signed SSL certificate)
│   └── server.key (Private key)
└── logs/
    └── server.log (Server activity log)
```

### Server Process
```
Startup (start-server.bat):
  ├─ Check Node.js installed ✓
  ├─ Navigate to project directory
  ├─ Run: npm start
  ├─ Load environment variables
  ├─ Start Express app
  ├─ Listen on port 8080
  ├─ Load SSL certificates
  ├─ Initialize database
  ├─ Print: "Server running on http://localhost:8080"
  └─ Ready for student connections

Running Server:
  ├─ Accept HTTP/HTTPS connections
  ├─ Process incoming requests
  ├─ Validate PIN, verify faces
  ├─ Write to local database
  ├─ Broadcast WebSocket updates
  ├─ Generate reports on-demand
  ├─ Log all activities
  └─ Monitor memory/CPU usage
```

### Features
```
Request Handling:
  ├─ Concurrent connections: 100+ students possible
  ├─ Response time: < 500ms typical
  ├─ Timeout: 30 seconds (configurable)
  └─ Error handling: Graceful degradation

Database Operations:
  ├─ Connection pooling: 5-10 connections
  ├─ Transaction support: ACID compliance
  ├─ Query optimization: Indexed on common fields
  ├─ Backup: Auto-backup every hour
  └─ Recovery: Automatic on server restart

WebSocket (Real-time Dashboard):
  ├─ Connection: Persistent (stays open)
  ├─ Update frequency: Instant (< 100ms)
  ├─ Bandwidth: Minimal (small event payloads)
  ├─ Scalability: Hundreds of connections possible
  └─ Fallback: Polling (if WebSocket unavailable)
```

## Component 3: Local Database (SQLite)

### Database Setup
```
File Location: ./database/sessions.db
File Format: SQLite 3 binary format
File Size: Typically 100MB-1GB (after many sessions)
Backup: Hourly snapshots + on-demand exports

Tables:
  ├─ Lecturers
  ├─ Students
  ├─ Courses
  ├─ Sessions
  ├─ AttendanceRecords
  ├─ FaceDescriptors
  ├─ Devices
  ├─ DigitalSignatures
  ├─ Reports
  └─ AuditLogs

Indexes:
  ├─ Session (courseID, sessionDate)
  ├─ Attendance (sessionID, studentID)
  ├─ Students (registrationNumber)
  └─ Devices (deviceID, lastSeen)
```

### Performance Characteristics
```
Query Speed:
  ├─ Simple SELECT: < 10ms
  ├─ COUNT query: < 20ms
  ├─ JOIN query (5 tables): < 50ms
  ├─ INSERT: < 5ms
  └─ Batch insert (100 records): < 100ms

Connection Pool:
  ├─ Size: 5-10 connections
  ├─ Timeout: 30 seconds
  ├─ Reuse: Enabled (faster queries)
  └─ WAL Mode: Enabled (better concurrency)
```

## Component 4: Student Devices (Connected to Hotspot)

### WiFi Connection
```
Device Type: Smartphone or tablet
OS: Android 5.0+ or iOS 12.0+
WiFi: Must support WPA2 at minimum
Browser: Any modern browser (Chrome, Safari, Firefox)

Connection Process:
  1. Device scans for available WiFi networks
  2. Student sees: "OWHAS-AK" in available networks
  3. Student taps to connect
  4. Prompts for password (shared by lecturer)
  5. Device obtains IP via DHCP (192.168.1.x range)
  6. DNS points to lecturer device
  7. Hotspot assigned via network manager
```

### Captive Portal Behavior
```
Automatic Page Opening (Captive Portal):
  1. Student connects to WiFi
  2. Operating system detects captive portal
     (Tries to reach canonical.com or equivalent)
  3. Gets redirected to: http://localhost:8080/hotspot.html
  4. Browser auto-opens registration page
  
Benefits:
  ├─ No typing required
  ├─ No manual URL entry
  ├─ Works on most modern phones
  └─ Seamless user experience

Fallback (if auto-open fails):
  └─ Student manually opens browser:
     ├─ http://localhost:8080
     └─ Redirects to hotspot.html
```

## Component 5: Communication Network

### Network Topology
```
               Lecturer Device
              (WiFi Hotspot + Server)
                     │
                ┌────┼────┐
                │    │    │
          Student1 Student2 Student3
          (Device1)(Device2)(Device3)

All on same local WiFi network
No internet required for offline mode
```

### Data Path (Offline)
```
Browser → HTTP → Port 8080 → Node.js → SQLite → Response
                   ↑
           Lecturer Device
```

### DNS Resolution (Offline)
```
Browser requests: GET http://localhost:8080/hotspot.html
  ↓
Device uses: 127.0.0.1 (localhost) on same device
  OR
Device uses: 192.168.1.1 (lecturer device IP via WiFi)

DNS:
  ├─ If manual entry: User types IP address
  ├─ If captive portal: Auto-redirect to default gateway
  └─ Resolution: Automatic via DHCP gateway
```

## Component 6: Storage & Backups

### Local Storage
```
Reports Generated:
  ├─ Location: ./public/reports/
  ├─ File format: PDF and XLSX
  ├─ Naming: {sessionID}_{timestamp}.pdf
  ├─ Size per session: ~200-500KB
  └─ Retention: Until manual deletion

Database Backup:
  ├─ Location: ./database/backup/
  ├─ Frequency: Hourly auto-backup
  ├─ Format: SQLite dump (.sql)
  ├─ Size: ~50-100MB typical
  └─ Retention: Keep 7 recent backups

Face Descriptors:
  ├─ Storage: In database (FaceDescriptors table)
  ├─ Size per descriptor: 512 bytes
  ├─ Total per session (50 students): ~25KB
  └─ Security: Encrypted in database

Session Log Files:
  ├─ Location: ./logs/
  ├─ Format: Text/JSON
  ├─ Size per session: ~10-50KB
  └─ Retention: 30 days
```

## Offline Mode Limitations & Considerations

```
Limitations:
  ├─ Single lecturer per hotspot
  ├─ Maximum ~100 students (WiFi hardware dependent)
  ├─ No remote access (unless VPN setup)
  ├─ No automatic cloud backup (manual export needed)
  ├─ No multi-session overlap (one session at a time)
  ├─ Data loss if device crashes (unless backed up)
  ├─ No geographic redundancy
  └─ Dependent on lecturer device availability

Considerations:
  ├─ Electricity: Battery or power supply needed
  ├─ WiFi range: ~30-50m typical indoor range
  ├─ Interference: Other networks on same channel
  ├─ Security: Device securing physical access
  ├─ Setup time: 2-5 minutes startup
  └─ Troubleshooting: Lecturer must resolve issues
```

## Security in Offline Mode

```
Network Security:
  ├─ WiFi encryption: WPA2 (strong)
  ├─ HTTPS: Self-signed certificate
  │  └─ Warning: Browser shows "untrusted" (expected)
  ├─ Local firewall: Only ports 8080/8443 open
  └─ Local network: No external access

Data Security:
  ├─ Database encryption: Optional (configurable)
  ├─ PIN encryption: AES-256 in DB
  ├─ Face descriptors: Stored as-is (no PII)
  ├─ Access control: Local file permissions
  └─ Audit logging: All operations logged

Physical Security:
  ├─ Device: Lecturer keeps with them
  ├─ WiFi password: Shared with class only
  ├─ USB backup: Periodically backed up
  └─ Anti-theft: Device physically secured
```

## Success Criteria
- All offline components clearly shown
- Hardware requirements documented
- Software stack detailed
- Server process flow visible
- Database structure specified
- Network topology clear
- Data flow paths shown
- Backup strategy documented
- Limitations and considerations listed
- Security mechanisms shown

## Tools Suitable For
- Draw.io
- Lucidchart
- Architecture diagram tools
- Deployment pipeline diagrams

## Related Sections in Final_Doc
- Section 9.1: Offline Deployment (Lecturer Hotspot)
- Section 9: Deployment Architecture
