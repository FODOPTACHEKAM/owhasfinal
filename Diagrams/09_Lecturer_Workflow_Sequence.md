# Diagram 09: Lecturer Complete Workflow - Sequence Diagram

## Purpose
Show the step-by-step sequence of interactions between lecturer, mobile app, local server, and cloud for a complete session lifecycle.

## Type
**UML Sequence Diagram**

## Actors/Participants
1. **Lecturer** (user)
2. **Flutter Mobile App** (lecturer client)
3. **Local Node.js Server**
4. **Local Database** (SQLite/JSON)
5. **Firebase Cloud** (optional)
6. **Live Dashboard** (in-app UI)

## Timeline Sequence

### Phase 1: Session Configuration and Setup

```
Lecturer: Opens Flutter app
  |
  ├─→ Flutter App: Display course list
  |       ├─→ Local Database: Query courses
  |       └─← Local Database: Return course list
  |
Lecturer: Selects course
  |
  ├─→ Flutter App: Show session configuration form
  |
Lecturer: Configures session (PIN, duration, max students, etc.)
  |
  ├─→ Flutter App: Validate configuration
  |       ├─ Check PIN format (4 digits)
  |       ├─ Check duration (> 0 minutes)
  |       └─ Check max students
  |
Lecturer: Clicks "Start Attendance Session"
  |
  ├─→ Flutter App: Prepare session start request
  |
  ├─→ Node.js Server: POST /api/session/start
  |       {courseID, PIN, duration, maxStudents, location, geofence}
  |       |
  |       ├─→ Server: Generate QR code token
  |       ├─→ Server: Create session object
  |       ├─→ Server: Encrypt PIN
  |       |
  |       ├─→ Local Database: INSERT Session record
  |       │   - sessionID (UUID)
  |       │   - PIN (encrypted)
  |       │   - QRCode
  |       │   - status = 'ACTIVE'
  |       │   - startTime = NOW()
  |       |
  |       ├─← Local Database: Confirmation
  |       |
  |       └─← Server: Response {sessionID, QR, PIN}
  |
  ├─← Flutter App: Display PIN and QR code
  |
Lecturer: See PIN (4-digit) displayed
  |
Lecturer: See QR code displayed
  |
Lecturer: Broadcasts PIN to class (verbally or displayed)
  |
Lecturer: Starts sending QR code to students
  |
  ├─→ Flutter App: Activate live dashboard updates
  |       |
  |       ├─→ Node.js Server: Open WebSocket connection
  |       │   (for real-time updates)
  |       |
  |       └─← Node.js Server: Ready for live updates
```

### Phase 2: Active Session Monitoring

```
[While students are registering...]

Student: Registers attendance (see Diagram 10)
  |
  ├─→ Node.js Server: POST /api/attendance/register
  |       {PIN, faceDescriptor, deviceID, location}
  |       |
  |       ├─→ Server: Validate PIN
  |       ├─→ Server: Verify face
  |       ├─→ Server: Check for duplicates
  |       ├─→ Server: Store AttendanceRecord
  |       └─← Server: Response {success}
  |
  ├─→ Node.js Server: WebSocket → Flutter App (real-time update)
  |       {attendeeCount, verifiedCount, newStudent: {name, time, verified}}
  |
  ├─← Flutter App: Update live dashboard
  |       - Refresh attendee list
  |       - Update statistics (present/absent)
  |       - Show duplicate warnings (if any)
  |       - Highlight unverified records

[This repeats for each student registration]

Lecturer: Monitors live dashboard in real-time
  |
  ├─→ Flutter App: Display current session stats
  |       - Total registered: N
  |       - Face verified: M
  |       - Pending verification: (N-M)
  |       - Duplicates detected: X
  |       - Live attendee list scrollable
  |
Lecturer: (Optional) Manually removes a student
  |
  ├─→ Flutter App: Display student list
  |
Lecturer: Swipe or tap to remove student
  |
  ├─→ Flutter App: DELETE student from session
  |
  ├─→ Node.js Server: POST /api/attendance/remove
  |       {recordID}
  |       |
  |       ├─→ Local Database: DELETE from AttendanceRecords
  |       └─← Local Database: Confirmation
  |
  ├─← Node.js Server: Response {success}
  |
  ├─← Flutter App: Update dashboard
  |
  ├─→ Live Dashboard: Refresh without removed student

[Continue monitoring until session end time]
```

### Phase 3: Session Ending

```
Lecturer: Decides session is complete
  |
Lecturer: Clicks "End Session" button
  |
  ├─→ Flutter App: Send end session request
  |
  ├─→ Node.js Server: POST /api/session/end
  |       {sessionID}
  |       |
  |       ├─→ Server: Finalize session
  |       ├─→ Server: Lock attendance records
  |       ├─→ Server: Calculate final statistics
  |       |
  |       ├─→ Local Database: UPDATE Sessions
  |       │   - status = 'ENDED'
  |       │   - endTime = NOW()
  |       |
  |       ├─← Local Database: Confirmation
  |       |
  |       └─← Server: Response {finalStats}
  |
  ├─← Flutter App: Display session end confirmation
  |
Lecturer: Sees message "Session ended"
```

### Phase 4: Report Generation

```
Lecturer: Clicks "Generate Report"
  |
  ├─→ Flutter App: Request report generation
  |
  ├─→ Node.js Server: POST /api/report/generate
  |       {sessionID, reportType: ['pdf', 'excel']}
  |       |
  |       ├─→ Server: Query AttendanceRecords
  |       ├─→ Server: Query Students info
  |       |
  |       ├─→ Local Database: SELECT * FROM AttendanceRecords
  |       │   WHERE sessionID = {sessionID}
  |       |
  |       ├─← Local Database: Return records
  |       |
  |       ├─→ Server: Generate PDF
  |       │   - Format attendance sheet
  |       │   - Include course details
  |       │   - Add lecturer signature
  |       │   - Include timestamp
  |       │   - Save to file system
  |       |
  |       ├─→ Server: Generate Excel
  |       │   - Create spreadsheet
  |       │   - Add columns: StudentID, Name, Time, Verified
  |       │   - Add summary stats
  |       │   - Save to file system
  |       |
  |       ├─→ Local Database: INSERT into Reports table
  |       │   - reportID
  |       │   - sessionID
  |       │   - filePath
  |       │   - generatedDate
  |       │   - fileSize
  |       |
  |       ├─← Local Database: Confirmation
  |       |
  |       └─← Server: Response {pdfPath, excelPath, fileSize}
  |
  ├─← Flutter App: Display report generation success
  |
Lecturer: Sees "Report generated successfully"
  |
Lecturer: (Optional) Preview reports
  |
  ├─→ Flutter App: Load PDF/Excel files from file system
  |
  ├─← Flutter App: Display report preview
  |
Lecturer: Confirms reports look correct
```

### Phase 5: Cloud Synchronization (Optional)

```
Lecturer: (Optional) Signs into Firebase cloud account
  |
  ├─→ Flutter App: Show Firebase login screen
  |
Lecturer: Enters email and password
  |
  ├─→ Flutter App: Authenticate with Firebase
  |
  ├─→ Firebase Auth: Verify credentials
  |
  ├─← Firebase Auth: Return JWT token
  |
  ├─← Flutter App: Store token locally
  |
Lecturer: (Optional) Clicks "Sync to Cloud"
  |
  ├─→ Flutter App: Prepare sync data
  |
  ├─→ Node.js Server: POST /api/cloud/sync
  |       {sessionID, authToken}
  |       |
  |       ├─→ Server: Validate auth token with Firebase
  |       ├─→ Server: Serialize session data
  |       ├─→ Server: Serialize all AttendanceRecords
  |       |
  |       ├─→ Firebase Firestore: POST /sessions/{sessionID}
  |       │   - Session metadata
  |       │   - Configuration
  |       |
  |       ├─→ Firebase Firestore: POST /records subcollection
  |       │   - All attendance records
  |       |
  |       ├─→ Firebase Cloud Storage: Upload PDF report
  |       │   - File: {sessionID}.pdf
  |       |
  |       ├─→ Firebase Cloud Storage: Upload Excel report
  |       │   - File: {sessionID}.xlsx
  |       |
  |       ├─→ Local Database: UPDATE Sessions
  |       │   - status = 'SYNCED'
  |       │   - cloudSyncTime = NOW()
  |       │   - cloudURL = {firestore_doc_url}
  |       |
  |       ├─← Local Database: Confirmation
  |       |
  |       └─← Server: Response {syncStatus: 'complete'}
  |
  ├─← Firebase: Confirm upload
  |
  ├─← Flutter App: Display sync success message
  |
Lecturer: Sees "Data synced to cloud successfully"
  |
Lecturer: (Optional) Shares session link from cloud
  |
  ├─→ Flutter App: Provide cloud access link
  |
Lecturer: Can now access session from any device via owhas.org
```

### Phase 6: Session Complete

```
Lecturer: All tasks completed
  |
  ├─→ Flutter App: Show session summary
  |       - Total students: N
  |       - Verified: M
  |       - Duplicates: X
  |       - Reports: Generated ✓
  |       - Cloud: Synced ✓
  |
Lecturer: Session workflow complete
  |
END
```

## Timing Annotations (Optional)
- Typical section durations:
  - Configuration: 1-2 minutes
  - Active monitoring: Variable (session duration)
  - Report generation: 5-10 seconds
  - Cloud sync: 10-30 seconds

## Error Scenarios (Optional Sub-sequences)
- Network disconnection during session
- Server crash and recovery
- Pin collision detected
- Face verification failure
- Database error during reporting

## Success Criteria
- Clear actor separation (vertical lines)
- All interactions shown as arrows
- Sequence numbers or clear left-to-right flow
- Response messages shown
- Decision points visible
- Time duration annotations (optional)
- Clear start and end
- Easy to trace complete session lifecycle

## Tools Suitable For
- Draw.io (sequence diagram template)
- Lucidchart
- Enterprise Architect
- Visual Paradigm
- PlantUML (sequence diagram syntax)

## Related Sections in Final_Doc
- Section 6.1: Lecturer Workflow - Session Creation to Report Generation
- Section 6: User Workflows
