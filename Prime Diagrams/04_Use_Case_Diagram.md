# Figure 4.4: Use Case Diagram

## Purpose
Shows interactions between users (Lecturer and Student) and the OwHAS system.

## Diagram Type
**UML Use Case Diagram**

## Actors

### Primary Actors

#### Lecturer
- **Description:** The educator who creates and manages attendance sessions
- **Use Cases:**
  1. **Login** — Authenticate with email/password via Firebase
  2. **Create Session** — Configure course, PIN, duration, geofence
  3. **Generate QR Code** — Create scannable QR with session connection info
  4. **Generate PIN** — Create 4-digit session access code
  5. **Start Server** — Launch Node.js backend on device
  6. **Monitor Attendance** — View live dashboard with attendee list and count
  7. **End Session** — Close registration, finalize attendee list
  8. **Export Reports** — Generate PDF and Excel attendance files
  9. **Sync to Firebase** — Upload session data to cloud

#### Student
- **Description:** The learner who registers their attendance
- **Use Cases:**
  1. **Connect to Hotspot** — Join lecturer's Wi-Fi network
  2. **Scan QR Code** — Scan displayed QR to open registration page
  3. **Enter PIN** — Submit 4-digit session code for validation
  4. **Register Attendance** — Fill form with name, matric number, details
  5. **Submit Face Image** — Capture and submit face for anti-proxy verification
  6. **Provide GPS Location** — Allow location access for geofence check (online mode)
  7. **Submit Digital Signature** — Sign on screen for additional verification (optional)

### Secondary Actors

#### Node.js Server
- **Use Cases:**
  - **Host Registration Page** — Serve captive portal HTML to student browsers
  - **Process Face Verification** — Run face-api.js models for duplicate detection
  - **Store Attendance Data** — Save records to local database

#### Firebase Cloud
- **Use Cases:**
  - **Authenticate Users** — Validate lecturer login credentials
  - **Store Session Data** — Persist attendance records in Firestore
  - **Store Files** — Save exported PDF/Excel reports

## Include Relationships (<<include>>)
- Create Session **<<includes>>** Generate PIN
- Create Session **<<includes>>** Generate QR Code
- Register Attendance **<<includes>>** Enter PIN
- Register Attendance **<<includes>>** Submit Face Image
- Export Reports **<<includes>>** End Session

## Extend Relationships (<<extend>>)
- Register Attendance **<<extends>>** Provide GPS Location (only in online mode)
- Register Attendance **<<extends>>** Submit Digital Signature (optional)
- Export Reports **<<extends>>** Sync to Firebase (only when internet available)

## System Boundary
**Inside the system:**
- All use cases listed above
- Session management logic
- Face recognition engine
- Report generation engine

**Outside the system:**
- Lecturer, Student (human actors)
- Firebase Cloud, Node.js Server (system actors)

## Drawing Instructions
1. Draw a large rectangle for the system boundary, label it "OwHAS"
2. Place Lecturer stick figure on the left
3. Place Student stick figure on the right
4. Place Node.js Server and Firebase Cloud as rectangles below
5. Draw use case ovals inside the system boundary
6. Connect actors to their use cases with solid lines
7. Show <<include>> with dashed arrows pointing to the included use case
8. Show <<extend>> with dashed arrows pointing to the base use case

## Tools
- Draw.io / diagrams.net
- Lucidchart
- StarUML
- Visual Paradigm
- PlantUML
