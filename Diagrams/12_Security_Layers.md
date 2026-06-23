# Diagram 12: Security Layers - Security Architecture Diagram

## Purpose
Show all security mechanisms and layers protecting the OWHAS system.

## Type
**Security Architecture Diagram / Layered Architecture**

## Security Layers (from outermost to innermost)

### Layer 1: Network Security
**Components:**
- WiFi Hotspot Encryption (WPA2/WPA3)
- HTTPS/TLS for all connections
- SSL Certificates (self-signed for offline, Let's Encrypt for cloud)
- Firewall rules (if applicable)
- VPN tunnel (optional for cloud)

**Security Mechanisms:**
- Encrypted data in transit
- Certificate pinning (optional)
- Anti-MITM (Man-in-the-Middle) protection
- Secure channel establishment

**Threats Mitigated:**
- Network eavesdropping
- Data interception
- Unauthorized access

### Layer 2: Authentication & Authorization
**Components:**
- PIN Validation (4-digit for session)
- Firebase Authentication (email/password)
- Session Token Generation (JWT)
- Role-based access control (Lecturer/Student/Admin)

**Security Mechanisms:**
- PIN encryption (AES-256)
- JWT tokens with expiration
- Secure token storage
- Multi-factor support (optional)

**Threats Mitigated:**
- Unauthorized session access
- Token forgery
- Session hijacking
- Privilege escalation

### Layer 3: Biometric Verification (Face Recognition)
**Components:**
- face-api.js (5 detection models)
- Face descriptor extraction (128-dim vectors)
- Duplicate detection algorithm
- Confidence threshold (0.6 default)

**Security Mechanisms:**
- Liveness detection (captures true face, not photos)
- Descriptor comparison (Euclidean distance)
- Anomaly detection (multiple registrations)
- Quality assessment (image validation)

**Threats Mitigated:**
- Proxy attendance
- Face spoofing (photos/videos)
- Impersonation
- Account takeover

### Layer 4: Device Fingerprinting
**Components:**
- Unique Device ID generation
- OS type and version capture
- Device model fingerprint
- Hardware identifier extraction
- Behavioral analysis (login patterns)

**Security Mechanisms:**
- Device registration per session
- Suspicious device flagging
- Device history tracking
- IP address logging (for cloud)

**Threats Mitigated:**
- Unknown device access
- Bot/automated attacks
- Device theft abuse
- Credential sharing across devices

### Layer 5: Location Verification (Online Mode)
**Components:**
- GPS geofencing
- Location accuracy validation
- Geofence center coordinates
- Geofence radius (meters)
- Periodic heartbeat location checks

**Security Mechanisms:**
- GPS coordinate validation
- Distance calculation (Haversine formula)
- Accuracy threshold enforcement
- Location refresh mechanism

**Threats Mitigated:**
- Remote attendance spoofing
- Remote proxy attempts
- Location fraud
- Off-campus unauthorized registration

### Layer 6: Data Encryption
**Components:**
- Database encryption (at rest)
- Field-level encryption for sensitive data
- PIN storage (hashed + salted)
- Face descriptor storage (if encrypted)
- Backup encryption

**Security Mechanisms:**
- AES-256 encryption
- Bcrypt password hashing
- Salted hashes (random per record)
- Encrypted database backups

**Threats Mitigated:**
- Data breach exposure
- Database compromise
- Credential theft
- Unauthorized data access

### Layer 7: Application-Level Security
**Components:**
- Input validation (all fields)
- SQL injection prevention (parameterized queries)
- XSS (Cross-Site Scripting) prevention
- CSRF (Cross-Site Request Forgery) tokens
- Rate limiting
- Session timeout

**Security Mechanisms:**
- Whitelist input validation
- Prepared statements (SQL)
- Content Security Policy (CSP)
- CSRF token verification
- Automatic logout after inactivity
- API rate limiting (requests/minute)

**Threats Mitigated:**
- SQL injection attacks
- XSS attacks
- CSRF attacks
- Brute force attacks
- Session fixation
- Denial of service (DoS)

### Layer 8: Audit & Monitoring
**Components:**
- Audit logging (all actions)
- Event tracking
- Suspicious activity detection
- Admin dashboards
- Alerts and notifications
- Incident response logs

**Security Mechanisms:**
- Immutable audit trail
- Real-time anomaly detection
- Administrator notifications
- Incident logging
- Forensic analysis capability
- Regular security reviews

**Threats Mitigated:**
- Unauthorized access (post-incident detection)
- Fraud detection
- Compliance violations
- Policy breaches

## Visual Structure

```
NETWORK LAYER (Perimeter)
├─ WiFi Encryption (WPA2/WPA3)
├─ HTTPS/TLS Encryption
├─ SSL Certificates
└─ Firewall Rules

AUTHENTICATION LAYER
├─ PIN Verification (4-digit)
├─ Firebase Auth (Cloud)
├─ JWT Token Generation
└─ Role-Based Access

BIOMETRIC LAYER
├─ Face Detection (5 models)
├─ Face Descriptor (128-dim)
├─ Duplicate Detection
└─ Quality Validation

DEVICE LAYER
├─ Device Fingerprinting
├─ OS/Model Validation
├─ Device History
└─ IP Address Logging

LOCATION LAYER (Online)
├─ GPS Geofencing
├─ Distance Calculation
├─ Accuracy Validation
└─ Heartbeat Verification

DATA LAYER
├─ Database Encryption (AES-256)
├─ PIN Hashing (Bcrypt)
├─ Sensitive Field Encryption
└─ Backup Encryption

APPLICATION LAYER
├─ Input Validation
├─ SQL Injection Prevention
├─ XSS/CSRF Prevention
├─ Rate Limiting
├─ Session Management
└─ Timeout Handling

AUDIT LAYER (Monitoring)
├─ Event Logging
├─ Suspicious Activity Detection
├─ Admin Notifications
├─ Forensic Trail
└─ Compliance Audit

USER/ATTACKER
(All layers provide defense in depth)
```

## Security Controls Summary

| Layer | Control | Type | Threat Coverage |
|-------|---------|------|-----------------|
| Network | TLS Encryption | Technical | Data in transit |
| Auth | PIN + JWT | Technical | Session access |
| Biometric | Face-api.js | Behavioral | Proxy attempts |
| Device | Fingerprinting | Technical | Unknown devices |
| Location | Geofencing | Technical | Remote spoofing |
| Data | Encryption | Technical | Data breach |
| App | Input validation | Technical | Injection attacks |
| Audit | Logging | Detective | Incident response |

## Defense in Depth Strategy
- Multiple layers ensure if one is breached, others provide protection
- No single point of failure
- Layered approach provides redundancy
- Progressive security (each layer adds to overall security)

## Key Encryption Standards
- **Transport:** TLS 1.2+
- **Database:** AES-256
- **Password:** Bcrypt (10 rounds minimum)
- **Hash:** SHA-256 with salt
- **Tokens:** JWT with HS256/RS256

## Compliance Considerations
- GDPR (data privacy)
- FERPA (educational records)
- Local data protection laws
- Institutional policies

## Success Criteria
- All layers visible and labeled
- Clear separation between layers
- Threats mitigated for each layer shown
- Technical controls identified
- Clear entry/exit attack vectors
- Defense-in-depth principle demonstrated
- Color coding by layer type

## Tools Suitable For
- Draw.io
- Lucidchart
- Visio
- Architecture diagramming tools

## Related Sections in Final_Doc
- Section 7: Security & Authentication
- Section 7.1: Security Architecture
