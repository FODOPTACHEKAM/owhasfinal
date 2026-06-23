# Figure 4.14: Device Fingerprinting Process

## Purpose
Shows the fraud prevention mechanism that identifies unique devices to prevent multiple registrations from the same device.

## Diagram Type
**Process Flow Diagram**

## Concept: Device Fingerprinting
Device fingerprinting creates a unique identifier for each student's device by combining multiple hardware and software attributes. This prevents a single student from registering attendance multiple times on the same device (e.g., using different names) or helps detect when the same device is used by different "students."

## Process Flow

### Step 1: Student Device
- **Input:** Student connects to hotspot and opens registration page
- **Device Types:** Smartphone (Android/iOS), Laptop (Windows/macOS/Linux), Tablet
- **Browser:** Chrome, Safari, Firefox, Edge, Samsung Internet

### Step 2: Device Information Collection
- **Collected Attributes:**

| Attribute | Source | Example | Uniqueness |
|-----------|--------|---------|------------|
| User-Agent String | Browser header | Mozilla/5.0 (Linux; Android 13; SM-A536B) | Medium |
| Screen Resolution | JavaScript | 1080x2400 | Low |
| Platform | navigator.platform | Linux armv81 | Low |
| Language | navigator.language | en-US | Low |
| Timezone | Intl.DateTimeFormat | Africa/Douala | Low |
| Hardware Concurrency | navigator.hardwareConcurrency | 8 | Low |
| Device Memory | navigator.deviceMemory | 6 | Low |
| Touch Support | navigator.maxTouchPoints | 5 | Low |
| Canvas Fingerprint | Canvas API rendering | Hash value | High |
| WebGL Renderer | WebGL API | Adreno (TM) 642L | High |
| IP Address | Server-side | 192.168.43.101 | Medium |
| MAC Address Hint | DHCP lease | Last 4 chars (limited) | Medium |

### Step 3: Fingerprint Generator
- **Algorithm:**
  1. Collect all device attributes from browser
  2. Concatenate attributes into a single string
  3. Apply hash function (SHA-256 or similar)
  4. Generate a unique fingerprint string
- **Output:** A string like `fp_a3b2c1d4e5f6...`
- **Storage:** Sent to server with the registration form

### Step 4: Duplicate Check
- **Process:**
  1. Receive fingerprint with new registration
  2. Query existing records for this session
  3. Compare fingerprint against all registered devices
  4. Check if this fingerprint already exists

### Step 5: Attendance Approval / Rejection

| Scenario | Fingerprint Match | Action |
|----------|-------------------|--------|
| New device, new student | No match | Approve registration |
| Same device, same name | Exact match | Reject (already registered) |
| Same device, different name | Fingerprint match, name mismatch | Flag as suspicious |
| Different device, same face | No fingerprint match, face match | Flag as potential proxy |

## Process Flow Diagram
```
[●] Start
  |
  v
[Student Device]
  - Phone / Laptop / Tablet
  |
  v
[Collect Device Information]
  - User-Agent
  - Screen Resolution
  - Platform, Language
  - Canvas Fingerprint
  - WebGL Renderer
  - IP Address
  |
  v
[Fingerprint Generator]
  - Concatenate attributes
  - Apply SHA-256 hash
  - Generate unique ID
  |
  v
[Send to Server with Registration]
  |
  v
[Duplicate Check]
  - Query session records
  - Compare fingerprints
  |
  v
◇ Fingerprint Exists?
  |No                    |Yes
  v                      v
[New Device]           ◇ Same Student Name?
  |                    |Yes              |No
  v                    v                 v
◇ Face Duplicate?   [Already           [SUSPICIOUS:
  |No       |Yes     Registered]        Same device,
  v         v         |                 different name]
[APPROVE] [FLAG:      v                   |
  |       Proxy?]   [REJECT:              v
  v         |       Duplicate]          [FLAG &
[Save      v          |                 WARN]
 Record] [WARN]       v                   |
  |        |        [Show Error]          v
  v        v           |               [Record with
[⊙]End  [⊙]End      [⊙]End            Warning]
                                          |
                                        [⊙]End
```

## Limitations
- **Browser Fingerprinting is not 100% unique:** Two identical phones with same OS version may produce similar fingerprints
- **Private/Incognito Mode:** May reduce fingerprint accuracy
- **VPN/Proxy:** Can mask IP address but other attributes remain
- **Device Reset:** A factory reset changes some attributes

## Complementary Security Measures
Device fingerprinting works alongside:
1. **Face Recognition** — biometric identity verification
2. **Session PIN** — access control
3. **GPS Geofencing** — location verification (online mode)
4. **Digital Signature** — additional identity confirmation

## Drawing Instructions
1. Flow top-to-bottom with clear process steps
2. Use rectangles for processes, diamonds for decisions
3. Show the data collection step with listed attributes
4. Branch for duplicate/new device paths
5. Color code: Green (approved), Red (rejected), Yellow (flagged)
6. Show the complementary security measures on the side

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
