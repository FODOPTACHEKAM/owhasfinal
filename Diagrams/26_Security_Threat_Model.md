# Diagram 26: Security Threat Model & Mitigation

## Purpose
Show security threats, attack vectors, and mitigation strategies.

## Type
**Threat Model Diagram / Security Risk Matrix**

## Threat Categories & Mitigation

### 1. Network-Level Threats

```
┌────────────────────────────────────────────────┐
│         NETWORK-LEVEL THREATS                 │
└────────────────────────────────────────────────┘

Threat 1: Man-in-the-Middle (MITM) Attack
─────────────────────────────────────────
Attack Type: Attacker intercepts network traffic
  ├─ Offline mode: WiFi traffic (unencrypted potential)
  ├─ Online mode: HTTPS (protected)
  └─ Risk level: HIGH (offline) → LOW (online)

Attack Vector:
  ├─ WiFi sniffer on same network
  ├─ Intercept PIN transmission
  ├─ Intercept session token
  ├─ Replay token for unauthorized access
  └─ Consequence: Unauthorized attendance registration

Mitigation Strategies:
  ├─ 1. HTTPS encryption (offline too)
  │  ├─ Self-signed certificate for offline
  │  ├─ Let's Encrypt for cloud
  │  └─ Encryption: AES-256 strong
  │
  ├─ 2. Certificate pinning (app level)
  │  ├─ Hard-code expected certificate
  │  ├─ Prevent proxy/MITM substitution
  │  └─ Effectiveness: Stops certificate-based MITM
  │
  ├─ 3. WPA2/WPA3 WiFi encryption
  │  ├─ Prevent WiFi sniffing
  │  └─ Encryption: AES (WPA2) or CCMP (WPA3)
  │
  └─ 4. VPN (optional for institutional)
     ├─ Encrypt all traffic end-to-end
     └─ Risk: Still needs to trust VPN provider

Risk Reduction: HIGH → LOW


Threat 2: Denial of Service (DoS)
──────────────────────────────────
Attack Type: Attacker floods server with requests
  ├─ Target: OwHAS server
  ├─ Goal: Make service unavailable
  └─ Risk level: MEDIUM

Attack Vector:
  ├─ 1000+ fake registration requests (flooding)
  ├─ Exhaust database connections
  ├─ Consume memory/CPU
  ├─ Consequence: Service unavailable for real users
  └─ Duration: 15-60 minutes possible

Mitigation Strategies:
  ├─ 1. Rate limiting
  │  ├─ Max 5 PIN attempts per minute per IP
  │  ├─ Max 100 requests per minute per IP
  │  └─ Blocks obvious flood attacks
  │
  ├─ 2. CloudFlare DDoS protection (cloud mode)
  │  ├─ Geo-blocking: Only legitimate IPs
  │  ├─ Challenge verification: CAPTCHA
  │  └─ Effectiveness: Stops most DDoS
  │
  ├─ 3. Load balancer auto-scaling
  │  ├─ Add servers when under attack
  │  └─ Absorb traffic spike
  │
  └─ 4. Connection timeout
     ├─ Drop idle connections after 30 seconds
     └─ Frees resources for new requests

Risk Reduction: MEDIUM → LOW


Threat 3: Rogue WiFi Access Point
──────────────────────────────────
Attack Type: Fake WiFi network with same name
  ├─ Attacker sets up: "OWHAS-AK" fake hotspot
  ├─ Students connect to fake (thinking it's real)
  ├─ Risk level: MEDIUM
  └─ Prerequisite: Attacker in classroom

Attack Consequence:
  ├─ Intercept PIN → Gain session access
  ├─ Intercept face data → Steal biometric
  ├─ Replay attack → Register fake students
  └─ Impact: Attendance fraud + data breach

Mitigation Strategies:
  ├─ 1. WiFi security features
  │  ├─ WPA2/WPA3 strong password
  │  ├─ Hidden SSID (optional, weak security)
  │  └─ MAC filtering (known student devices only)
  │
  ├─ 2. Lecturer announcement
  │  ├─ Announce SSID at start of class
  │  ├─ Announce password
  │  └─ Manual verification by students
  │
  ├─ 3. Certificate pinning (app)
  │  ├─ App only accepts known certificate
  │  ├─ Fake hotspot can't impersonate
  │  └─ Effectiveness: Very high
  │
  └─ 4. Frequency hopping (future)
     ├─ Server/app use temporary channels
     └─ Attacker can't easily intercept

Risk Reduction: MEDIUM → LOW

```

### 2. Application-Level Threats

```
┌────────────────────────────────────────────────┐
│       APPLICATION-LEVEL THREATS               │
└────────────────────────────────────────────────┘

Threat 1: SQL Injection
───────────────────────
Attack Type: Attacker inserts SQL code into input
  ├─ Example: PIN = "1234' OR '1'='1"
  ├─ Goal: Bypass validation, extract data
  └─ Risk level: HIGH (if not mitigated)

Attack Vector:
  ├─ PIN input field
  ├─ Student name input
  ├─ Course search
  └─ Any database query field

Consequence:
  ├─ Extract all student names and emails
  ├─ Modify attendance records
  ├─ Delete session data
  └─ Escalation: Possible RCE (Remote Code Execution)

Mitigation Strategies:
  ├─ 1. Parameterized queries (PRIMARY)
  │  ├─ Use prepared statements
  │  ├─ Separate SQL from data
  │  └─ Prevents injection
  │
  ├─ 2. Input validation
  │  ├─ PIN: Numeric only, 4-6 digits
  │  ├─ Name: Alphabetic + spaces
  │  └─ Reject invalid input
  │
  ├─ 3. Principle of Least Privilege
  │  ├─ Database user: Limited permissions
  │  ├─ Can't execute DROP, DELETE on critical tables
  │  └─ Damage limitation if injected
  │
  └─ 4. ORM (Object-Relational Mapping)
     ├─ Abstraction layer (e.g., TypeORM, Sequelize)
     └─ Parameterization automatic

Risk Reduction: HIGH → VERY LOW


Threat 2: Cross-Site Scripting (XSS)
─────────────────────────────────────
Attack Type: Attacker injects JavaScript code
  ├─ Runs in victim's browser
  ├─ Can steal cookies, session tokens
  └─ Risk level: MEDIUM

Attack Vector:
  ├─ Student name field: "<img src=x onerror=alert('xss')>"
  ├─ Course description: JavaScript code
  └─ Anywhere user input displayed

Consequence:
  ├─ Steal session cookie → Hijack account
  ├─ Redirect to phishing site
  ├─ Keylogger → Steal password
  └─ Deface web page

Mitigation Strategies:
  ├─ 1. Input sanitization (CRITICAL)
  │  ├─ Remove HTML tags from user input
  │  ├─ Escape special characters
  │  └─ Library: DOMPurify, bleach
  │
  ├─ 2. Content Security Policy (CSP)
  │  ├─ HTTP header: Restrict script sources
  │  ├─ Block inline scripts
  │  └─ Whitelist allowed domains
  │
  ├─ 3. HttpOnly cookies
  │  ├─ Cookie not accessible from JavaScript
  │  ├─ Protects session token
  │  └─ Standard practice
  │
  └─ 4. Output encoding
     ├─ Encode data before displaying
     ├─ Browser interprets as text (not code)
     └─ Framework: Angular, React (automatic)

Risk Reduction: MEDIUM → LOW


Threat 3: Session Hijacking
────────────────────────────
Attack Type: Attacker steals/intercepts session token
  ├─ Token in cookie or header
  ├─ Attacker uses token to impersonate user
  └─ Risk level: MEDIUM (with HTTPS: LOW)

Attack Vector:
  ├─ Unencrypted transmission (intercept)
  ├─ Cookie theft (malware on device)
  ├─ Brute force (guess token)
  └─ Session fixation (force known token)

Consequence:
  ├─ Register fake students under lecturer account
  ├─ Modify attendance records
  ├─ Download confidential reports
  └─ Escalation: Compromise attendance database

Mitigation Strategies:
  ├─ 1. HTTPS encryption (MANDATORY)
  │  ├─ Token transmitted encrypted
  │  └─ Prevents interception
  │
  ├─ 2. Secure cookies
  │  ├─ HttpOnly: Not accessible from JavaScript
  │  ├─ Secure: Only transmitted over HTTPS
  │  ├─ SameSite: Prevent cross-origin access
  │  └─ Combined: Very secure
  │
  ├─ 3. Short token lifetime
  │  ├─ Session token: Valid 1 hour
  │  ├─ Refresh token: Valid 7 days
  │  ├─ Automatic refresh required
  │  └─ Reduces window of opportunity
  │
  ├─ 4. Token rotation
  │  ├─ Generate new token on each request
  │  └─ Invalidate old token
  │
  └─ 5. IP address binding (optional)
     ├─ Token tied to specific IP
     ├─ IP change = re-authentication required
     └─ Trade-off: Breaks mobile handoff

Risk Reduction: MEDIUM → LOW
```

### 3. Biometric & Authentication Threats

```
┌──────────────────────────────────────────────┐
│    BIOMETRIC & AUTHENTICATION THREATS       │
└──────────────────────────────────────────────┘

Threat 1: Face Spoofing (Impersonation)
───────────────────────────────────────
Attack Type: Attacker uses fake/stolen face
  ├─ Method 1: Print high-resolution face photo
  ├─ Method 2: Video replay of student's face
  ├─ Method 3: Deepfake video
  └─ Risk level: MEDIUM

Attack Goal:
  ├─ Register attendance as another student
  ├─ Commit attendance fraud
  └─ Consequence: False attendance record

Mitigation Strategies:
  ├─ 1. Liveness detection
  │  ├─ Detect if face is real (not photo/video)
  │  ├─ Check for: Blinking, head movement, depth
  │  ├─ Library: face-api.js (limited), specialized tools
  │  └─ Effectiveness: 90-95% against simple spoofing
  │
  ├─ 2. Multi-factor verification
  │  ├─ PIN verification: Ensures it's the student
  │  ├─ GPS verification: Location confirmation
  │  ├─ Device fingerprinting: Consistent device
  │  └─ Combined: Difficult to spoof all three
  │
  ├─ 3. Device fingerprinting
  │  ├─ Track device ID, OS, browser
  │  ├─ Detect different device → Alert lecturer
  │  └─ Not foolproof but adds friction
  │
  ├─ 4. Lecturer review (HIGH-RISK cases)
  │  ├─ Duplicate face: Require manual approval
  │  ├─ Unknown device: Require verification
  │  └─ Human judgment as final arbiter
  │
  └─ 5. Continuous monitoring
     ├─ Track attendance patterns
     ├─ Detect anomalies (e.g., student in 2 places)
     └─ Alert for investigation

Risk Reduction: MEDIUM → LOW


Threat 2: Credential Stuffing (PIN Brute Force)
────────────────────────────────────────────────
Attack Type: Attacker tries many PIN combinations
  ├─ PIN length: 4-6 digits
  ├─ Possible combinations: 10,000 - 1,000,000
  ├─ Without rate limiting: Could brute force quickly
  └─ Risk level: HIGH (if unmitigated)

Attack Vector:
  ├─ Automated bot: Sends 10,000 requests quickly
  ├─ Each attempt: Wrong PIN → Try next
  ├─ Timing: 10,000 PINs × 100ms = 16 minutes
  └─ Without detection: Success possible

Consequence:
  ├─ Attacker discovers valid PIN
  ├─ Can register fake students
  ├─ Attendance fraud
  └─ Escalation: Mass fraud possible

Mitigation Strategies:
  ├─ 1. Rate limiting (CRITICAL)
  │  ├─ Max 5 PIN attempts per minute per IP
  │  ├─ After 5 failures: Locked out for 15 minutes
  │  └─ Exponential backoff: 15m → 30m → 1hr
  │
  ├─ 2. Account lockout
  │  ├─ After 10 failed attempts: Account locked
  │  ├─ Requires lecturer/admin unlock
  │  └─ Prevents rapid-fire attacks
  │
  ├─ 3. Session-specific PIN
  │  ├─ Each session has unique PIN
  │  ├─ Old PIN becomes invalid
  │  └─ Reduces reuse risk
  │
  ├─ 4. Log suspicious activity
  │  ├─ Alert on multiple failed attempts
  │  ├─ Track by IP address
  │  └─ Allow manual investigation
  │
  └─ 5. CAPTCHA after failures
     ├─ After 2 failed attempts: Show CAPTCHA
     └─ Prevents bot automation

Risk Reduction: HIGH → LOW


Threat 3: Stolen/Forgotten PIN
───────────────────────────────
Attack Type: PIN revealed to unauthorized person
  ├─ Scenario 1: Student writes PIN on hand
  ├─ Scenario 2: Student shows PIN to friend
  ├─ Scenario 3: PIN visible on presenter screen
  └─ Risk level: MEDIUM

Consequence:
  ├─ Unauthorized person registers fake attendance
  ├─ Easy impersonation (no biometric needed)
  └─ Fraud

Mitigation Strategies:
  ├─ 1. One-time PIN
  │  ├─ PIN valid for limited time only
  │  ├─ Expires after session ends
  │  └─ Reduces window of opportunity
  │
  ├─ 2. Combination verification (BEST)
  │  ├─ PIN alone doesn't register attendance
  │  ├─ Requires PIN + Face + GPS + Signature
  │  ├─ Much harder to fake all four
  │  └─ Effective deterrent
  │
  └─ 3. Lecturer awareness
     ├─ Don't write PIN on board (display method)
     ├─ Verbal announcement only
     └─ Emphasize: "Don't share your PIN"

Risk Reduction: MEDIUM → LOW
```

### 4. Data Privacy Threats

```
┌─────────────────────────────────────────────┐
│          DATA PRIVACY THREATS              │
└─────────────────────────────────────────────┘

Threat 1: Unauthorized Data Access
───────────────────────────────────
Attack Type: Attacker accesses sensitive data
  ├─ Sensitive data: Face descriptors, student names, emails
  ├─ Risk level: HIGH
  └─ Impact: Privacy breach

Attack Vector:
  ├─ Compromise database server
  ├─ Exploit SQL injection → Extract data
  ├─ Unsecured backups
  └─ Insider threat (IT staff)

Consequence:
  ├─ Student privacy violation
  ├─ Face descriptor exposure → Impersonation risk
  ├─ FERPA violation (education records)
  └─ Legal liability

Mitigation Strategies:
  ├─ 1. Database encryption
  │  ├─ Encrypt sensitive columns: face descriptors, emails
  │  ├─ Key stored separately
  │  └─ Decryption requires key + permissions
  │
  ├─ 2. Access control (RBAC)
  │  ├─ Lecturer: Can only see own students' data
  │  ├─ Admin: Can see all (with audit logging)
  │  ├─ Student: Can only see own records
  │  └─ Enforce at application + database level
  │
  ├─ 3. Audit logging
  │  ├─ Log all database access
  │  ├─ Who accessed what, when, why
  │  └─ Use for investigation & compliance
  │
  ├─ 4. Data minimization
  │  ├─ Only collect necessary data
  │  ├─ Delete old attendance records (2+ years)
  │  └─ Reduce exposure if breach occurs
  │
  ├─ 5. Secure backups
  │  ├─ Backup encryption: AES-256
  │  ├─ Stored separately (different location)
  │  ├─ Access restricted (need 2 keys)
  │  └─ Verified restorable (test regularly)
  │
  └─ 6. HTTPS & VPN
     ├─ All data in transit encrypted
     └─ Network-level protection

Risk Reduction: HIGH → LOW


Threat 2: Data Breach / Ransomware
──────────────────────────────────
Attack Type: Attacker encrypts/steals data
  ├─ Ransomware: Encrypt database
  ├─ Exfiltration: Steal and publish data
  └─ Risk level: HIGH

Consequence:
  ├─ Service unavailable (until decrypted or restored)
  ├─ Data loss or corruption
  ├─ Legal liability + fines (GDPR, FERPA)
  └─ Ransom demand (if ransomware)

Mitigation Strategies:
  ├─ 1. Regular backups
  │  ├─ Daily automated backups
  │  ├─ Weekly full backup
  │  ├─ 7-day retention minimum
  │  └─ Allows recovery if hit
  │
  ├─ 2. Backup verification
  │  ├─ Test restoration monthly
  │  ├─ Verify data integrity
  │  └─ Ensures backups are usable
  │
  ├─ 3. Backups offline/immutable
  │  ├─ Store backup copy air-gapped
  │  ├─ Prevent ransomware from encryption
  │  └─ Write-once backups (WORM)
  │
  ├─ 4. Network segmentation
  │  ├─ Database server isolated
  │  ├─ Limited network access
  │  └─ Prevents lateral movement
  │
  ├─ 5. Endpoint protection
  │  ├─ Antivirus on all systems
  │  ├─ Regular scanning
  │  └─ Block malware
  │
  └─ 6. Incident response plan
     ├─ Documented procedures
     ├─ Contact information
     ├─ Recovery prioritization
     └─ Communication templates

Risk Reduction: HIGH → MEDIUM
```

## Summary Risk Matrix

```
┌──────────────────────────────────────────────────────────────┐
│                  THREAT RISK SUMMARY                         │
├─────────────────────────────────┬─────────┬─────────┬────────┤
│ Threat                          │ Severity│ Likelihood│ Risk  │
├─────────────────────────────────┼─────────┼─────────┼────────┤
│ Man-in-the-Middle (WiFi)        │ High    │ Medium  │ HIGH   │
│ DoS Attack                       │ Medium  │ Low     │ MEDIUM │
│ Rogue WiFi Access Point         │ High    │ Low     │ MEDIUM │
│ SQL Injection                   │ Critical│ Low     │ MEDIUM │
│ XSS Attack                      │ Medium  │ Low     │ LOW    │
│ Session Hijacking               │ High    │ Low     │ MEDIUM │
│ Face Spoofing                   │ High    │ Medium  │ HIGH   │
│ PIN Brute Force                 │ Medium  │ Low     │ MEDIUM │
│ Stolen PIN                      │ Medium  │ Medium  │ MEDIUM │
│ Unauthorized Data Access        │ Critical│ Low     │ MEDIUM │
│ Data Breach / Ransomware        │ Critical│ Low     │ MEDIUM │
└─────────────────────────────────┴─────────┴─────────┴────────┘

Risk Rating Legend:
  ├─ CRITICAL: Urgent mitigation required
  ├─ HIGH: Implement mitigation immediately
  ├─ MEDIUM: Plan mitigation (medium-term)
  └─ LOW: Monitor, mitigate as resources allow

Status: All critical threats have mitigation in place
```

## Success Criteria
- All major threat categories identified
- Attack vectors clearly explained
- Consequences of each threat detailed
- Mitigation strategies specific and actionable
- Defense-in-depth approach shown
- Risk levels assessed
- Priority clear (what to fix first)
- Tools and technologies specified
- Incomplete mitigations highlighted
- Security best practices evident

## Tools Suitable For
- Draw.io (threat model diagram)
- Lucidchart
- Risk matrix
- Threat modeling tools (ThreatDragon, IriusRisk)

## Related Sections in Final_Doc
- Section 7: Security & Threat Mitigation
- Section 12: System Limitations & Edge Cases
