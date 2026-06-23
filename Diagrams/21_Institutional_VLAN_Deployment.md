# Diagram 21: Institutional VLAN Deployment

## Purpose
Show the institutional server deployment at ICTU for school-wide attendance system integration.

## Type
**Institutional Network Architecture Diagram**

## ICTU Institutional Deployment

```
┌──────────────────────────────────────────────────┐
│      ICTU INSTITUTIONAL VLAN DEPLOYMENT          │
│    (On-Premises School Server Integration)       │
│         Domain: atd.ictu.loc                     │
│         IP: 10.13.14.164 (VLAN)                 │
└──────────────────────────────────────────────────┘
```

## Network Topology

### ICTU Infrastructure
```
Internet ← Firewall (DMZ Protection)
             │
        Boundary Router
             │
        ┌────┴─────┬──────────┬──────────┐
        │           │          │          │
    VLAN 10      VLAN 13   VLAN 20    VLAN 30
  (Admin)      (Faculty)  (Student)  (Guest)
        │           │          │
        │      [ICTU Server]   │
        │      10.13.14.164    │
        │       atd.ictu.loc   │
        │           │          │
    [Server]   [Switch]   [Access Points]
```

### ICTU Server Details
```
Location: School data center (Climate controlled)
Server Model: Dell PowerEdge R750
CPU: Dual Intel Xeon Gold 6348
RAM: 256GB
Storage: 2TB SSD (RAID 5)
Network: Dual 10Gbps NICs (redundancy)

Operating System: Ubuntu 20.04 LTS (Server Edition)
Kernel: Linux 5.15+
Uptime: 99.95% SLA
```

## Network Configuration

### VLAN Setup
```
VLAN 13 (Faculty VLAN):
  ├─ IP Range: 10.13.14.0/24
  ├─ Gateway: 10.13.14.1
  ├─ DHCP Server: 10.13.14.2
  ├─ OwHAS Server: 10.13.14.164
  ├─ Subnet Mask: 255.255.255.0
  ├─ Connected: Lecturers, faculty computers
  └─ Access: Full access to OwHAS server

VLAN 20 (Student VLAN):
  ├─ IP Range: 10.13.20.0/24
  ├─ Gateway: 10.13.20.1
  ├─ Connected: Student devices (WiFi + wired)
  ├─ Access: Limited (controlled by firewall rules)
  └─ Can access: OwHAS server (port 443 only)

Firewall Rules:
  ├─ VLAN 13 → 10.13.14.164:443 (HTTPS): ALLOW
  ├─ VLAN 20 → 10.13.14.164:443 (HTTPS): ALLOW
  ├─ VLAN 13 → 10.13.14.164:8080 (HTTP): ALLOW (admin)
  ├─ VLAN 20 → Internet: ALLOW (web browsing)
  ├─ All other traffic: DENY (blocked)
  └─ Logging: All denied attempts logged
```

### DNS Configuration
```
Domain Name: atd.ictu.loc (local domain)
DNS Server: 10.13.14.5
TTL: 300 seconds

DNS Records:
  ├─ atd.ictu.loc → 10.13.14.164 (A record)
  ├─ www.atd.ictu.loc → 10.13.14.164 (CNAME)
  ├─ api.atd.ictu.loc → 10.13.14.164 (CNAME)
  └─ admin.atd.ictu.loc → 10.13.14.164 (CNAME)

Internal Only:
  ├─ Not accessible from internet
  ├─ Only resolvable within ICTU network
  └─ Requires VPN for off-campus access
```

## Application Server Setup

### OwHAS Backend (Institutional Version)
```
Installation:
  ├─ Path: /var/www/owhas-institutional
  ├─ Runtime: Node.js v18 LTS
  ├─ Port: 8080 (HTTP)
  ├─ HTTPS: Port 443 (via Nginx reverse proxy)
  └─ Process Manager: systemd service

Configuration:
  ├─ Environment: PRODUCTION (institutional)
  ├─ Database: PostgreSQL (on-premises)
  ├─ Authentication: ICTU LDAP/Active Directory
  ├─ Cloud sync: Optional (to Firebase)
  └─ Logging: Centralized (ELK stack)
```

## Authentication Integration

### LDAP/Active Directory Binding
```
LDAP Server: 10.13.14.50 (ICTU Directory Server)
Port: 389 (LDAP) or 636 (LDAPS)
Bind DN: cn=owhas,ou=services,dc=ictu,dc=loc
Search Base: ou=staff,dc=ictu,dc=loc

Lecturer Authentication:
  1. Lecturer enters email/password
  2. App queries LDAP:
     ├─ Verify username exists in ou=staff
     ├─ Verify password against LDAP hash
     ├─ Retrieve department from LDAP
     └─ Retrieve email from LDAP
  3. If valid: Generate JWT token
  4. Token valid for: 8 hours (institutional setting)

Student Authentication:
  1. Student enters registration number
  2. App queries LDAP:
     ├─ Verify student exists in ou=students
     ├─ Retrieve full name from LDAP
     └─ Retrieve enrolled courses from LDAP
  3. If valid: Create temporary session
  4. Proceed with face registration
```

### Directory Integration Benefits
```
✓ Single sign-on (SSO) integration
✓ Centralized user management
✓ Automatic sync of user info
✓ Department-based access control
✓ Course enrollment from SIS
✓ No duplicate user database
✓ Password policy inherited from AD
✓ Audit trail from directory server
```

## Database Configuration

### PostgreSQL (On-Premises)
```
Instance: PostgreSQL 13+
Location: 10.13.14.100 (separate server)
Port: 5432
Replication: On-premises secondary server
Backup: Daily (7-day retention)

Databases:
  ├─ owhas_prod (main database)
  ├─ owhas_archive (historical data)
  └─ owhas_backup (backup staging)

Connection from OwHAS:
  ├─ Host: 10.13.14.100
  ├─ Port: 5432
  ├─ User: owhas_app (limited privileges)
  ├─ SSL: Required (TLS 1.2+)
  └─ Connection pool: 20-50 connections
```

## Student Information System (SIS) Integration

### Two-Way Sync
```
ICTU SIS ↔ OwHAS Database

Data Sync Points:
  ├─ Student list: Synced daily (enrollment)
  ├─ Course registration: Synced daily
  ├─ Attendance data: Synced nightly (one-way)
  ├─ Reports: Exported to SIS weekly (automated)
  └─ Academic calendar: Synced at semester start

Sync Method:
  ├─ API calls: Between systems
  ├─ Batch processes: Scheduled (off-peak hours)
  ├─ Error handling: Retry with alert
  └─ Logging: Detailed sync logs maintained
```

## API Endpoints (Institutional)

### For Institutional Integration
```
POST /api/institution/sync/students
  ├─ Purpose: Import student list from SIS
  ├─ Auth: Institutional admin token
  └─ Payload: Array of student records

POST /api/institution/sync/courses
  ├─ Purpose: Import course offerings
  ├─ Auth: Institutional admin token
  └─ Payload: Array of course records

POST /api/institution/report/export
  ├─ Purpose: Export session reports to SIS
  ├─ Auth: Institutional admin token
  ├─ Format: CSV, JSON, XML (configurable)
  └─ Destination: SIS file drop (SFTP)

GET /api/institution/dashboard
  ├─ Purpose: Aggregate institutional statistics
  ├─ Auth: Institutional admin token
  ├─ Data: Total sessions, students, attendance rates
  └─ Filtering: By department, semester, etc.
```

## Security in Institutional Deployment

### Network-Level Security
```
Firewall Configuration:
  ├─ Inbound: Only HTTP/HTTPS (ports 80, 443)
  ├─ Outbound: Limited to necessary services
  ├─ VPN Access: For off-campus administrators
  ├─ Intrusion Detection: Enabled
  ├─ DDoS Protection: Rate limiting enabled
  └─ WAF Rules: Custom rules for known attacks

Access Control:
  ├─ Role-Based: Admin, Lecturer, Student
  ├─ IP Whitelisting: For admin access
  ├─ VPN Required: For remote access
  ├─ Multi-Factor Auth: Enabled for admins
  └─ Session timeout: 8 hours (configurable)
```

### Data Security
```
Encryption:
  ├─ Data at rest: AES-256 (database encryption)
  ├─ Data in transit: TLS 1.2+ (HTTPS only)
  ├─ Backups: Encrypted and stored separately
  ├─ Credentials: Not logged or stored in plain text
  └─ Face descriptors: Encrypted with institution key

Compliance:
  ├─ FERPA: Family Educational Rights & Privacy Act
  ├─ Data Residency: All data stored on-premises
  ├─ Audit Logging: All access logged with timestamps
  ├─ Data Retention: 7 years per educational standards
  └─ Vendor Assessment: ICTU IT security approved
```

## Support & Maintenance

### Institutional IT Support
```
Support Level: Silver (8-5 business hours)
Response Time: 2 hours for critical issues
Escalation: ICTU IT help desk (extension 1234)

Maintenance Windows:
  ├─ Scheduled: Every Sunday 2-4 AM UTC
  ├─ Emergency: On-demand (with notification)
  ├─ Backup: Daily at midnight
  ├─ Log rotation: Weekly
  └─ Patching: As needed (after testing)

Administrator Training:
  ├─ Basic: 4 hours (user management)
  ├─ Advanced: 8 hours (troubleshooting, backups)
  ├─ Documentation: Complete admin manual
  └─ Refresher: Annually
```

## Reporting & Compliance

### Compliance Reports
```
Generated Automatically:
  ├─ Monthly: System uptime report
  ├─ Monthly: Security incident log
  ├─ Quarterly: Attendance statistics (by department)
  ├─ Annually: Year-end attendance summary
  ├─ Annually: Data audit (FERPA compliance)
  └─ On-demand: Custom reports

Data Exports:
  ├─ Format: CSV, XLSX, PDF (selectable)
  ├─ Frequency: On-demand or scheduled
  ├─ Recipients: Department chairs, registrar
  ├─ Security: Signed & encrypted exports
  └─ Audit trail: All exports logged

Integration with Registrar:
  ├─ Final attendance: Auto-exported (grade input)
  ├─ Format: Registrar-specified CSV
  ├─ Schedule: End of each semester
  └─ Validation: Confirmed before grade posting
```

## Institutional Cost Model

```
One-Time Setup:
  ├─ Server hardware: ~$20,000
  ├─ Network configuration: ~$5,000
  ├─ Installation & testing: ~$10,000
  └─ Training & documentation: ~$5,000
     Total: ~$40,000

Annual Operating Costs:
  ├─ Server maintenance: ~$3,000
  ├─ Staff time (PT support): ~$10,000
  ├─ Backup storage: ~$1,000
  ├─ License/support: ~$5,000
  └─ Security audits: ~$2,000
     Total: ~$21,000/year
```

## Scalability for Institution

### Growth Plan
```
Current (Phase 1): 1 server, 5000 users
  ├─ Capacity: Handle 500 concurrent registrations
  └─ Deployment time: 1-2 years

Growth (Phase 2): 2-3 servers with load balancer
  ├─ Capacity: Handle 2000 concurrent registrations
  ├─ Deployment time: Year 2-3
  └─ Cost: Additional $50K hardware

Optimization (Phase 3): Distributed caching (Redis)
  ├─ Capacity: Handle 5000+ concurrent registrations
  ├─ Deployment time: Year 3+
  └─ Cost: Additional $15K for Redis cluster
```

## Success Criteria
- Institutional network architecture shown
- VLAN setup and firewall rules documented
- LDAP/AD integration explained
- SIS integration visible
- Database configuration detailed
- Security mechanisms comprehensive
- Compliance requirements addressed
- Support model defined
- Cost structure documented
- Scalability plan shown

## Tools Suitable For
- Draw.io (network diagram)
- Lucidchart
- Visio (for detailed network diagrams)
- Network diagramming tools

## Related Sections in Final_Doc
- Section 9.3: Institutional Server Deployment
- Section 9: Deployment Architecture
