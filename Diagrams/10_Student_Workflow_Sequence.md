# Diagram 10: Student Complete Workflow - Sequence Diagram

## Purpose
Show the step-by-step sequence of interactions between student, browser, local server, and face-api for a complete registration.

## Type
**UML Sequence Diagram**

## Actors/Participants
1. **Student** (user)
2. **Mobile Browser** (student client, web portal)
3. **hotspot.html** (client-side JavaScript)
4. **face-api.js** (face detection library)
5. **Local Node.js Server**
6. **Local Database**

## Complete Timeline Sequence

### Phase 1: Connection and Captive Portal

```
Student: Powers on phone and opens WiFi settings
  |
Student: Sees lecturer's hotspot SSID available
  |
Student: Connects to hotspot SSID
  |
  └─→ Wi-Fi Hotspot: Establishes connection
      (Device gets DHCP IP address)
  |
  ├─← Wi-Fi Hotspot: Connected notification

Student: Hotspot connected
  |
  ├─→ Student's Browser: Auto-opens captive portal
  |       (OS automatically tries to reach http://connectivity-check)
  |
  ├─→ Node.js Server: HTTP request received
  |
  ├─→ Local Database: Log connection attempt
  |
  ├─→ Node.js Server: Redirect to hotspot.html
  |
  ├─← Server: Return hotspot.html page
  |
  ├─← Browser: Display registration form
  |
Student: Sees registration page automatically (no typing needed!)
  |
  ├─→ Browser: Load JavaScript files
  |       - face-api.min.js (complete face detection library)
  |       - Custom registration script
  |       - UI styling
  |
  ├─→ Browser: Initialize face-api.js models
  |       - Loading face detection models (~30-50MB)
  |       - Loading face landmark models
  |       - Loading face expression models
  |
  └─← Browser: Models loaded and ready
```

### Phase 2: PIN Verification

```
Student: Sees registration form with fields:
  - PIN input (4 digits)
  - Camera preview
  - Start button

Student: Enters PIN (e.g., "1234")
  |
  ├─→ Browser (hotspot.html): Validate PIN format
  |       - Check length = 4
  |       - Check all numeric
  |       - Show error if invalid format
  |
Student: Clicks "Verify PIN" or "Next" button
  |
  ├─→ Browser: Prepare PIN submission
  |
  ├─→ hotspot.html: POST /api/attendance/verify-pin
  |       {
  |         pin: "1234",
  |         sessionToken: null,
  |         deviceID: "fingerprint123"
  |       }
  |
  ├─→ Node.js Server: Receive PIN request
  |       |
  |       ├─→ Server: Retrieve active session
  |       ├─→ Server: Retrieve session PIN (encrypted)
  |       ├─→ Server: Decrypt stored PIN
  |       ├─→ Server: Compare with submitted PIN
  |       |
  |       ├─ If PIN doesn't match:
  |       │   ├─→ Local Database: Log failed PIN attempt
  |       │   └─← Server: Response {error: "Invalid PIN"}
  |       |
  |       └─ If PIN matches:
  |           ├─→ Server: Generate session token
  |           ├─→ Server: Create temporary student session
  |           └─← Server: Response {token, sessionID, sessionInfo}
  |
  ├─← Browser: Receive response
  |
  ├─ If error: Display "Invalid PIN - Try again"
  |       Student: Reenter PIN (loop back)
  |
  └─ If success: Proceed to face capture
      └─→ Browser: Show face capture interface
```

### Phase 3: Camera Access

```
Student: Clicks "Start Face Registration"
  |
  ├─→ Browser: Request camera permission
  |       - Display permission dialog
  |
Student: Sees "App wants to use your camera" permission prompt
  |
Student: Grants camera permission ("Allow")
  |
  ├─→ Browser: Access device camera stream
  |       - Get MediaStream from device
  |       - Display live video preview
  |
  ├─← Camera: Streaming video frames
  |
  ├─→ Browser: Update video preview element
  |
Student: Sees live camera preview on screen
```

### Phase 4: Face Detection and Capture

```
Student: Positions face in frame
  |
  ├─→ Browser: Continuously process video frames
  |       (Every 100-200ms)
  |       |
  |       ├─→ face-api.js: Detect faces in frame
  |       │   - Run CNN face detection
  |       │   - Return face detection results
  |       |
  |       ├─ If no face detected:
  |       │   └─→ UI: Show "Position your face in the frame"
  |       |
  |       ├─ If one face detected:
  |       │   ├─→ UI: Show green rectangle around face
  |       │   ├─→ UI: Show "Face detected - Click capture"
  |       |
  |       └─ If multiple faces detected:
  |           └─→ UI: Show error "Only one face allowed - Ask others to leave"
  |
Student: Adjusts position until face is well-centered
  |
Student: Clicks "Capture Face" button
  |
  ├─→ Browser: Capture current video frame
  |       - Take snapshot from video stream
  |       - Save as canvas image
  |
  ├─→ hotspot.html: Call face-api.js descriptor extraction
  |       |
  |       ├─→ face-api.js: Compute face descriptors
  |       │   - Extract 128-dimensional vector
  |       │   - Represents unique facial features
  |       │   - Normalized and standardized
  |       |
  |       ├─← face-api.js: Return descriptor array
  |       |
  |       └─→ Browser: Store descriptor in memory
  |
  ├─→ Browser: Optional image validation
  |       - Check face quality score
  |       - Check brightness
  |       - Check angle
  |       - Show warning if poor quality
  |
Student: Sees "Face captured successfully" (or asked to retake)
```

### Phase 5: Face Verification and Duplicate Detection

```
Lecturer's Server: Student submitted face descriptor
  |
  ├─→ Browser: POST /api/attendance/verify-face
  |       {
  |         sessionToken: "token123",
  |         faceDescriptor: [0.234, 0.567, ...128 values],
  |         imageData: "base64encoded..."
  |       }
  |
  ├─→ Node.js Server: Receive face descriptor
  |       |
  |       ├─→ Server: Retrieve all descriptors in session
  |       ├─→ Local Database: Query FaceDescriptors table
  |       │   WHERE sessionID = {current_session}
  |       |
  |       ├─← Local Database: Return descriptor list
  |       |
  |       ├─→ Server: Compare new descriptor with each stored
  |       │   For each stored descriptor:
  |       │     distance = calculateEuclideanDistance(
  |       │       newDescriptor, storedDescriptor
  |       │     )
  |       │
  |       ├─ If distance < threshold (0.6):
  |       │   ├─→ Server: Potential duplicate detected!
  |       │   ├─→ Server: Store comparison details
  |       │   ├─→ Server: Flag record as duplicate
  |       │   └─ Possible faces:
  |       │      - Same person different ID
  |       │      - Different person spoofing
  |       |
  |       └─ If distance >= threshold for all:
  |           └─→ Server: Face is unique, proceed
  |
  |       ├─→ Local Database: INSERT into FaceDescriptors
  |       │   - descriptorID, studentID, descriptor array
  |       |
  |       ├─← Local Database: Confirmation
  |       |
  |       └─← Server: Response {verified: true/false, duplicateWarning}
  |
  ├─← Browser: Receive verification response
  |
  ├─ If duplicate detected:
  |   ├─→ Browser: Show warning overlay
  |   ├─→ Browser: "Face similar to another registrant - Verify with lecturer"
  |   ├─→ Lecturer App: Alert lecturer of possible proxy
  |
  └─ If unique:
      └─→ Browser: Proceed to next step (Location/Signature)
```

### Phase 6: Location Verification (Online Mode Only)

```
[Only in online/hybrid mode - optional in offline mode]

Student: Sees "Verify Location" step
  |
  ├─→ Browser: Request GPS permission
  |
Student: Grants GPS permission
  |
  ├─→ Browser: Acquire GPS location
  |       - Request Geolocation API
  |       - Acquire latitude, longitude, accuracy
  |       - May take 5-30 seconds depending on signal
  |
  ├─ If GPS timeout:
  |   ├─→ Browser: Show "Unable to get GPS - Retry or Skip"
  |   └─ Student can retry or proceed without location
  |
  └─ If GPS acquired:
      ├─→ Browser: Send location to server
      |
      ├─→ Node.js Server: Verify location within geofence
      |       |
      |       ├─→ Server: Calculate distance from geofence center
      |       │   distance = haversineDistance(
      |       │     latitude, longitude,
      |       │     geofence_lat, geofence_long
      |       │   )
      |       |
      |       ├─ If distance <= radius:
      |       │   └─→ Location verified ✓
      |       |
      |       └─ If distance > radius:
      |           ├─→ Browser: Show refresh button
      |           ├─→ UI: "You appear to be outside the classroom"
      |           ├─→ UI: "Tap to refresh your location"
      |           └─ Student can retry GPS
      |
      |       ├─→ Local Database: Store location in GPSLocations
      |
      |       └─← Server: Response {withinGeofence, distance}
      |
      ├─← Browser: Receive location verification
      |
      └─→ Browser: Display location result on screen
```

### Phase 7: Digital Signature (Optional)

```
Student: Sees "Digital Signature" section
  |
  ├─ Option 1: Sign on screen
  |   |
  |   ├─→ Browser: Display signature pad
  |   |
  |   Student: Draws signature with finger
  |   |
  |   ├─→ Browser: Capture signature strokes
  |   |
  |   Student: Clicks "Confirm Signature"
  |   |
  |   ├─→ Browser: Convert signature to image
  |   |
  |   └─→ hotspot.html: Store signature data
  |
  └─ Option 2: Skip signature
      └─→ Browser: Proceed without signature
```

### Phase 8: Final Submission

```
Student: Reviews registration data:
  - Name: {auto-filled}
  - Time: {timestamp}
  - PIN: Verified ✓
  - Face: Captured ✓
  - Location: Verified ✓
  - Signature: {optional}
  |
Student: Clicks "Submit Registration"
  |
  ├─→ Browser: Prepare final submission
  |
  ├─→ hotspot.html: POST /api/attendance/register
  |       {
  |         sessionToken: "token123",
  |         deviceID: "fingerprint456",
  |         registrationData: {
  |           faceDescriptor: [...],
  |           location: {lat, lon, accuracy},
  |           signature: "base64image",
  |           timestamp: "ISO8601",
  |           verificationMethod: "face"
  |         }
  |       }
  |
  ├─→ Node.js Server: Receive final registration
  |       |
  |       ├─→ Server: Validate all data integrity
  |       ├─→ Server: Verify session still active
  |       ├─→ Server: Final duplicate check
  |       |
  |       ├─→ Local Database: CREATE AttendanceRecord
  |       │   INSERT INTO AttendanceRecords (
  |       │     sessionID, studentID, deviceID,
  |       │     registrationTime, verificationMethod,
  |       │     faceConfidence, location, signature
  |       │   ) VALUES (...)
  |       |
  |       ├─→ Local Database: CREATE DigitalSignature (if provided)
  |       |
  |       ├─← Local Database: Confirmation
  |       |
  |       ├─→ Server: Update session attendee count
  |       ├─→ Server: Broadcast update to lecturer dashboard
  |       |
  |       └─← Server: Response {success: true, recordID}
  |
  ├─← Browser: Receive success response
  |
Student: Sees confirmation screen:
  |
  ├─ Message: "✓ Attendance Recorded Successfully"
  ├─ Timestamp: "Registered at 14:32:15"
  ├─ Course: "{Course Name}"
  ├─ Attendance Status: "PRESENT"
  |
  ├─→ Browser: Play success sound/animation
  |
Student: Can now close browser or go back
```

## Response Time Expectations
- PIN verification: < 500ms
- Face capture and extraction: 2-5 seconds
- Face verification and duplicate check: < 1-2 seconds
- Location verification: 5-30 seconds (GPS dependent)
- Final submission: < 1 second
- **Total time: 10-40 seconds** (depending on GPS)

## Error Scenarios (Optional)
- Network timeout during submission
- Server error (database full, etc.)
- Session ended while registering
- PIN expired (session ended)
- Duplicate face detected → manual verification needed

## Success Criteria
- Clear sequence of student interactions
- All system components visible
- Decision points for errors shown
- Response times indicated
- Optional steps clearly marked
- Easy to understand student perspective
- Shows both client and server processing

## Tools Suitable For
- Draw.io
- Lucidchart
- Enterprise Architect
- Visual Paradigm
- PlantUML

## Related Sections in Final_Doc
- Section 6.2: Student Workflow - Registration to Attendance Confirmation
- Section 6: User Workflows
