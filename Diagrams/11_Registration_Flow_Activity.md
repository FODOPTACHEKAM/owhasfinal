# Diagram 11: Detailed Registration Flow - Activity Diagram

## Purpose
Show the complete registration process with all decision points, loops, and error handling in an activity flow format.

## Type
**UML Activity Diagram or Flowchart**

## Main Flow Structure

### Activities and Decision Points

```
START
  ↓
[1. Student Connects to Hotspot]
  ├─ Browser auto-opens registration page
  ├─ hotspot.html loads (with face-api.js)
  ├─ Page displays PIN entry form
  └─ Status: Ready for input
  ↓
[2. PIN Entry]
  ├─ Student enters 4-digit PIN
  └─ Student clicks "Verify PIN"
  ↓
(DECISION) PIN Format Valid?
  ├─ NO → Show error "Invalid format"
  │   │    └─ Action: Go back to PIN entry [Loop]
  │   │
  └─ YES → Continue
  ↓
[3. Send PIN to Server]
  ├─ POST /api/attendance/verify-pin
  ├─ Server retrieves active session
  └─ Server compares PIN
  ↓
(DECISION) PIN Matches Session?
  ├─ NO → Server returns error
  │   │    ├─ Show "Invalid PIN"
  │   │    ├─ Increment failed attempts
  │   │    └─ Action: Go back to PIN entry [Loop or Lockout]
  │   │
  └─ YES → Server generates session token
  ↓
(DECISION) Has Camera?
  ├─ NO → Option 1: Manual Registration [Switch to Manual Flow]
  │   │    └─ Lecturer approves manually
  │   │
  └─ YES → Request camera permission
  ↓
[4. Camera Permission]
  ├─ Browser: Geolocation.getUserMedia() request
  ├─ User: Grants/Denies permission dialog
  ↓
(DECISION) Camera Permission Granted?
  ├─ NO → Show error "Camera required for face verification"
  │   │    ├─ Option 1: Try again
  │   │    ├─ Option 2: Manual registration
  │   │    └─ Action: [Conditional branch]
  │   │
  └─ YES → Start video stream
  ↓
[5. Face Detection Loop]
  ├─ Initialize video preview
  ├─ Load face-api.js models (if not loaded)
  ├─ Start continuous face detection
  ├─ Display: "Position face in frame"
  └─ Process frames every 100-200ms
  ↓
(DECISION) Face Detected in Current Frame?
  ├─ NO → Continue loop (frames keep processing)
  │   │    ├─ Show: "Position your face"
  │   │    ├─ Timeout after 30 seconds?
  │   │    │   └─ YES → Show "Unable to detect face - Try again"
  │   │    │   └─ NO → Keep waiting [Loop]
  │   │    └─ Action: [Loop back to face detection]
  │   │
  └─ YES → One or multiple faces detected?
  ↓
(DECISION) Multiple Faces in Frame?
  ├─ YES → Show error "Multiple faces detected"
  │   │    ├─ Display: "Only you should be in frame"
  │   │    ├─ Wait for others to leave
  │   │    └─ Action: [Loop back to face detection]
  │   │
  └─ NO → One face confirmed
  ↓
[6. Face Quality Check]
  ├─ Evaluate face quality metrics
  │  - Brightness level
  │  - Face size (not too close/far)
  │  - Angle (frontal view)
  │  - Blur detection
  ├─ Calculate quality score
  └─ Status: Show "Face detected - Good quality"
  ↓
[7. Student Clicks Capture]
  ├─ User confirms face is ready
  ├─ Browser captures current frame
  └─ Extracts face snapshot
  ↓
[8. Face Descriptor Extraction]
  ├─ Run face-api.js on captured image
  ├─ Compute 128-dimensional descriptor
  ├─ Extract facial landmarks
  └─ Calculate confidence score
  ↓
(DECISION) Face Quality Adequate?
  ├─ NO → Show "Poor image quality - Retake"
  │   │    ├─ Display: Brightness/angle issue
  │   │    ├─ Offer: "Retake photo" button
  │   │    └─ Action: [Loop back to face detection]
  │   │
  └─ YES → Face descriptor ready
  ↓
[9. Send Face to Server for Verification]
  ├─ POST /api/attendance/verify-face
  ├─ Send descriptor (128-dim array)
  ├─ Send image data (optional)
  └─ Server starts duplicate check
  ↓
[10. Server Duplicate Detection]
  ├─ Query all face descriptors in session
  ├─ Compare new descriptor with each
  ├─ Calculate Euclidean distance
  └─ Check: distance < threshold (0.6)?
  ↓
(DECISION) Duplicate Face Detected?
  ├─ YES → Possible proxy attempt!
  │   │    ├─ Log suspicious activity
  │   │    ├─ Alert lecturer dashboard
  │   │    ├─ Set duplicateDetected = TRUE
  │   │    ├─ Show warning to student: "Your face resembles another registrant"
  │   │    │                           "Please verify with lecturer"
  │   │    ├─ Return code: DUPLICATE_DETECTED
  │   │    └─ Action: [Continue or block based on policy]
  │   │
  └─ NO → Face is unique
  ↓
[11. Store Face Descriptor]
  ├─ Server: Save to FaceDescriptors table
  ├─ Server: Associate with studentID
  ├─ Server: Mark verification status
  └─ Status: FACE_VERIFIED
  ↓
(DECISION) Online Mode Session?
  ├─ NO → Skip GPS verification
  │   │    └─ Action: [Jump to signature section]
  │   │
  └─ YES → Require GPS verification
  ↓
[12. GPS Permission Request]
  ├─ Browser: Geolocation.getCurrentPosition() request
  ├─ User: Grants/Denies permission
  └─ Show spinner: "Acquiring location..."
  ↓
(DECISION) GPS Available & Accurate?
  ├─ NO → GPS timeout (> 30 seconds)
  │   │    ├─ Show error: "Unable to get GPS location"
  │   │    ├─ Offer options:
  │   │    │  - Retry GPS
  │   │    │  - Skip location check
  │   │    │  - Try again later
  │   │    └─ Action: [Conditional branch]
  │   │
  └─ YES → Location acquired (lat, lon, accuracy)
  ↓
[13. Verify Location Within Geofence]
  ├─ Server: Calculate distance from geofence center
  ├─ Formula: Haversine(student_location, geofence_center)
  ├─ Compare: distance <= radius?
  ├─ Result: withinGeofence = true/false
  └─ Store in GPSLocations table
  ↓
(DECISION) Within Geofence?
  ├─ NO → Outside classroom boundary!
  │   │    ├─ Show warning: "You appear to be outside the classroom"
  │   │    ├─ Display: Distance from geofence
  │   │    ├─ Offer: "Refresh Location" button
  │   │    ├─ Student can tap to re-acquire GPS
  │   │    └─ Action: [Loop back to GPS or Continue anyway]
  │   │
  └─ YES → Location verified within geofence
  ↓
[14. Optional Signature Capture]
  ├─ Display: "Provide digital signature (optional)"
  ├─ Show signature pad on screen
  ├─ Student draws signature or skips
  ├─ If drawn: Convert to image
  └─ Store signature image path
  ↓
(DECISION) Provide Signature?
  ├─ YES → Signature captured
  │   │    └─ Status: SIGNATURE_CAPTURED
  │   │
  └─ NO → Skip signature
       └─ Status: NO_SIGNATURE
  ↓
[15. Device Fingerprinting]
  ├─ Generate unique device ID
  ├─ Extract: OS, model, unique identifiers
  ├─ Hash to create fingerprint
  ├─ Check if device seen before
  └─ Store in Devices table
  ↓
(DECISION) Device Flagged as Suspicious?
  ├─ YES → Device has history of proxy attempts
  │   │    ├─ Show warning: "This device has been flagged"
  │   │    ├─ Notify lecturer
  │   │    ├─ Require manual verification
  │   │    └─ Action: [Escalation]
  │   │
  └─ NO → Device is trustworthy
  ↓
[16. Final Data Validation]
  ├─ Verify PIN still valid (session active)
  ├─ Verify face descriptor present
  ├─ Verify session not exceeded max students
  ├─ Verify student not already registered twice
  └─ All checks pass?
  ↓
(DECISION) All Validations Pass?
  ├─ NO → Something went wrong
  │   │    ├─ Show error message
  │   │    ├─ Log error details
  │   │    └─ Action: [Offer retry or contact lecturer]
  │   │
  └─ YES → Ready to finalize registration
  ↓
[17. Create AttendanceRecord]
  ├─ Server: INSERT into AttendanceRecords table
  ├─ Fields:
  │  - sessionID, studentID, timestamp
  │  - faceConfidence, location, signature
  │  - verificationMethod, duplicateDetected
  ├─ Transaction: Atomic write
  └─ Receive: recordID confirmation
  ↓
[18. Update Session Statistics]
  ├─ Increment attendee count
  ├─ Update verified count
  ├─ Update duplicate count (if applicable)
  └─ Refresh dashboard broadcast via WebSocket
  ↓
[19. Display Confirmation]
  ├─ Show: "✓ Attendance Recorded Successfully"
  ├─ Display: Timestamp, course name, status
  ├─ Play: Success sound/animation
  ├─ Offer: Close browser or try next student
  └─ Status: REGISTRATION_COMPLETE
  ↓
(DECISION) Is Student Done?
  ├─ YES → Close browser
  │   │    └─ END
  │   │
  └─ NO → Reload page for next student
       └─ Action: [Loop back to START]
  ↓
END
```

## Error Handling Flows (Sub-activities)

### Flow A: Camera Not Available
```
START (No Camera)
  ├─ Option 1: Use Manual Registration
  │   └─ Lecturer manually adds student
  └─ Option 2: Retry with another device
```

### Flow B: Network Disconnection
```
START (Network Loss)
  ├─ Detect connection lost during submission
  ├─ Show: "Connection lost - Retrying..."
  ├─ Attempt to reconnect (exponential backoff)
  ├─ Success? → Complete registration
  └─ Failure? → Ask to retry or manual registration
```

### Flow C: Duplicate Face (Proxy Attempt)
```
START (Duplicate Detected)
  ├─ Display warning to student
  ├─ Alert lecturer dashboard
  ├─ Two options:
  │  1. Student verifies with lecturer in person
  │  2. Lecturer manually approves/denies in app
  └─ Continue with lecturer decision
```

## Visual Elements
- **Start/End**: Oval/rounded shape
- **Activity**: Rectangle
- **Decision**: Diamond with condition inside
- **Arrows**: Flow direction, labeled with YES/NO, [Loop], etc.
- **Merge Point**: Junction where paths converge
- **Fork**: Path split for parallel activities (if any)
- **Swimlanes**: (Optional) Separate client/server activities

## Key Decision Points Summary
1. PIN format valid?
2. PIN matches session?
3. Has camera?
4. Camera permission granted?
5. Face detected?
6. Multiple faces?
7. Face quality adequate?
8. Duplicate face detected?
9. Online mode?
10. GPS available?
11. Within geofence?
12. Provide signature?
13. Device flagged?
14. All validations pass?
15. Is student done?

## Success Criteria
- All decision points visible and labeled
- All error paths shown and handled
- Loops clearly marked
- Both success and failure flows present
- Optional steps indicated
- Easy to follow from start to end
- Shows feedback to user at each step
- Clear entry/exit points

## Tools Suitable For
- Draw.io (Activity diagram)
- Lucidchart
- Enterprise Architect
- Visual Paradigm
- Miro/Mural (collaborative)
- PlantUML (activity syntax)

## Related Sections in Final_Doc
- Section 6.3: Registration Process Flow (Activity Diagram)
- Section 6: User Workflows
