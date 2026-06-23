# Diagram 08: Data Relationship Flowchart

## Purpose
Show how data flows through the system from the point of registration through to report generation and cloud sync.

## Type
**Data Flow Diagram (DFD) or Process Flow Diagram**

## Main Data Flow Paths

### Path 1: Offline Registration Flow
```
1. START: Student connects to hotspot
   ↓
2. Browser auto-opens hotspot.html (captive portal)
   ↓
3. Student submits 4-digit PIN
   ↓
4. PIN VALIDATION: Local server checks session PIN
   ├─ Invalid? → Display error → Retry (back to step 3)
   └─ Valid? → Continue
   ↓
5. FACE CAPTURE: Student takes photo
   ↓
6. FACE DETECTION: face-api.js processes image on client
   ├─ No face detected? → Ask to retake (back to step 5)
   ├─ Multiple faces? → Ask to use single face (back to step 5)
   └─ Face detected? → Extract descriptor (128-dim vector)
   ↓
7. FACE VERIFICATION: Compare descriptor with stored descriptors
   ├─ Descriptor stored in AttendanceRecords table
   ├─ Check for duplicates (same student, different person)
   └─ Calculate similarity score
   ↓
8. DUPLICATE CHECK
   ├─ If match confidence > threshold (0.6) → Possible proxy detected
   │   ├─ Show warning to student
   │   ├─ Show warning to lecturer (live dashboard)
   │   └─ Flag record with duplicateDetected = TRUE
   └─ If confidence < threshold → Unique face → Continue
   ↓
9. OPTIONAL: GPS VERIFICATION (online mode only)
   ├─ Request device GPS location
   ├─ Check if within geofence
   └─ Store location in AttendanceRecords
   ↓
10. OPTIONAL: DIGITAL SIGNATURE
    ├─ Student provides signature on screen
    └─ Store signature image in DigitalSignatures table
    ↓
11. DEVICE FINGERPRINT: Generate unique device ID
    ├─ Extract OS, model, unique identifier
    ├─ Hash to create fingerprint
    └─ Store in Devices table
    ↓
12. CREATE ATTENDANCE RECORD
    ├─ Write to AttendanceRecords table:
    │  - sessionID, studentID, timestamp, faceConfidence
    │  - verificationMethod, location, deviceID
    │  - faceDescriptor (in FaceDescriptors table)
    └─ Update session attendee count
    ↓
13. LIVE DASHBOARD UPDATE
    ├─ WebSocket to lecturer app
    ├─ Update attendee list
    ├─ Refresh statistics (total, verified, pending)
    └─ Trigger alerts if duplicate detected
    ↓
14. CONFIRMATION TO STUDENT
    ├─ Display success message
    ├─ Show recorded attendance timestamp
    └─ Show QR code (optional: for manual verification)
    ↓
15. END: Registration complete, data stored locally
```

### Path 2: Session Ending and Report Generation
```
1. START: Lecturer clicks "End Session"
   ↓
2. SESSION STATE UPDATE
   ├─ Change status from ACTIVE to ENDED
   ├─ Record end time
   └─ Lock further registrations
   ↓
3. ATTENDANCE DATA COMPILATION
   ├─ Query AttendanceRecords table for session
   ├─ Count total records
   ├─ Calculate present/absent
   ├─ Identify duplicates
   └─ Aggregate statistics
   ↓
4. PDF REPORT GENERATION
   ├─ Fetch session metadata (course, date, time)
   ├─ Compile attendance list with timestamps
   ├─ Calculate attendance percentage
   ├─ Add course details
   ├─ Add lecturer signature (if configured)
   ├─ Generate PDF file
   └─ Save to local storage with sessionID
   ↓
5. EXCEL REPORT GENERATION
   ├─ Create spreadsheet from AttendanceRecords
   ├─ Add columns: StudentID, Name, Timestamp, Verified, Face%
   ├─ Add summary sheet with stats
   ├─ Calculate cumulative attendance (if previous sessions uploaded)
   ├─ Generate Excel file (.xlsx)
   └─ Save to local storage
   ↓
6. UPDATE SESSION STATUS
   ├─ Change status from ENDED to EXPORTED
   ├─ Record export timestamp
   └─ Store file paths and checksums in Reports table
   ↓
7. OPTIONAL: CUMULATIVE ATTENDANCE
   ├─ If lecturer uploaded previous sessions
   ├─ Load cumulative data from history
   ├─ Merge with current session records
   ├─ Recalculate overall attendance percentage
   └─ Include in report footer
   ↓
8. END (Local): Reports generated and stored locally
```

### Path 3: Cloud Synchronization Flow
```
1. START: Lecturer initiates cloud sync (or auto-sync enabled)
   ↓
2. AUTHENTICATION CHECK
   ├─ Check if lecturer is signed into Firebase
   ├─ If not signed in → Redirect to login
   ├─ If signed in → Retrieve JWT token
   └─ Continue
   ↓
3. PREPARE SYNC DATA
   ├─ Serialize session data to JSON
   ├─ Serialize attendance records
   ├─ Serialize face descriptors (optional: PII considerations)
   ├─ Serialize reports (PDF/Excel files)
   └─ Create sync batch
   ↓
4. UPLOAD TO FIREBASE
   ├─ POST session data to Firestore /sessions/{sessionID}
   ├─ POST records to Firestore /sessions/{sessionID}/records/
   ├─ Upload PDF to Cloud Storage /reports/{sessionID}.pdf
   ├─ Upload Excel to Cloud Storage /reports/{sessionID}.xlsx
   └─ Monitor upload progress
   ↓
5. CONFLICT RESOLUTION (if data exists in cloud)
   ├─ Check for existing sessionID in cloud
   ├─ If conflict → Compare timestamps
   ├─ Keep most recent version
   └─ Log merge operation in AuditLogs
   ↓
6. VERIFY UPLOAD
   ├─ Check Firestore document creation
   ├─ Verify file checksums in Cloud Storage
   ├─ Confirm all records received
   └─ On error → Retry or queue for later
   ↓
7. UPDATE LOCAL DATABASE
   ├─ Change session status to SYNCED
   ├─ Record cloud sync timestamp
   ├─ Store cloud file URLs
   ├─ Mark records as backed up
   └─ Update Reports table with cloudURL
   ↓
8. NOTIFICATION TO LECTURER
   ├─ Display sync success message
   ├─ Show timestamp and record count
   ├─ Provide cloud access links
   └─ Offer option to download from cloud
   ↓
9. END: Cloud backup complete, data distributed
```

### Path 4: Data Backup and Recovery
```
1. START: Automatic backup triggered (scheduled) or manual backup
   ↓
2. IDENTIFY DATA TO BACKUP
   ├─ All sessions from past 30 days
   ├─ Associated attendance records
   ├─ Face descriptors
   ├─ Reports
   └─ Device fingerprints
   ↓
3. CREATE BACKUP PACKAGE
   ├─ Serialize database to JSON or SQLite dump
   ├─ Compress all files (tar.gz or zip)
   ├─ Generate checksum (MD5/SHA256)
   ├─ Encrypt backup (if sensitive)
   └─ Add metadata (backup date, version, size)
   ↓
4. STORE BACKUP
   ├─ Local copy: App internal storage
   ├─ Cloud copy: Cloud Storage bucket
   ├─ Optional: External drive or USB
   └─ Log backup in AuditLogs
   ↓
5. RECOVERY PROCESS (if needed)
   ├─ Restore from latest backup
   ├─ Verify checksum integrity
   ├─ Decrypt if encrypted
   ├─ Re-populate database
   ├─ Notify lecturer of recovery
   └─ Validate data consistency
   ↓
6. END: Data backup secured, recovery available
```

## Key Data Stores

### Local (On Lecturer Device)
- AttendanceRecords table
- FaceDescriptors table
- Devices table
- Sessions table
- Reports (PDF/Excel files)

### Cloud (Firebase)
- Firestore /sessions collection
- Firestore /records subcollection
- Cloud Storage /reports bucket
- Cloud Storage /archives bucket

## Data Transformation Points
1. **Capture** → Raw face image → Face descriptor (128-D vector)
2. **Verification** → Multiple descriptors → Similarity scores
3. **Aggregation** → Individual records → Session statistics
4. **Export** → Database records → PDF/Excel formatted documents
5. **Sync** → Local JSON → Firebase documents
6. **Archive** → Active data → Compressed backup

## Key Information to Display
- Data source and destination
- Process names
- Decision points (diamonds)
- Data stores (cylinders/rectangles)
- Flow direction (arrows)
- Data transformations
- Optional vs mandatory steps
- Error/retry paths

## Success Criteria
- All major data flows visible
- Clear start and end points
- Decision branches shown
- Data transformations indicated
- Integration points with cloud visible
- Error handling paths included
- Easy to trace data from registration to report

## Tools Suitable For
- Draw.io
- Lucidchart
- Miro/Mural (collaborative)
- Flowchart software

## Related Sections in Final_Doc
- Section 5.3: Data Relationship Flowchart
- Section 6: User Workflows
- Section 8: API & Integration
