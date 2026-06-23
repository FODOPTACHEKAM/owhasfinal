# Figure 4.6: QR Check-In Flowchart

## Purpose
Shows the QR code attendance process from generation to recorded attendance.

## Diagram Type
**Flowchart**

## Flow Steps

### Step 1: Generate QR Code
- **Actor:** Lecturer (via Flutter app)
- **Action:** System generates a QR code containing:
  - Server IP address (e.g., 192.168.x.1:8080)
  - Session PIN (4-digit code)
  - Session ID
- **Output:** QR code displayed on lecturer's screen

### Step 2: Student Scans QR
- **Actor:** Student
- **Action:** Student uses phone camera or QR scanner app to scan the displayed QR code
- **Result:** Phone opens browser with the registration URL pre-filled with session info
- **Alternative:** Student can manually enter the server URL and PIN

### Step 3: Open Registration Form
- **Actor:** Student's browser
- **Action:** Browser navigates to `http://192.168.x.1:8080/hotspot.html`
- **Result:** Registration form loads with:
  - PIN field (auto-filled from QR)
  - Name field
  - Matriculation number field
  - Face capture button
  - Signature pad (optional)

### Step 4: Submit Information
- **Actor:** Student
- **Action:** Student fills in all required fields:
  1. Verifies/enters session PIN
  2. Enters full name
  3. Enters matriculation number
  4. Captures face image via camera
  5. Optionally draws digital signature
- **Validation:** Client-side validation before submission

### Step 5: Save Attendance
- **Actor:** Node.js Server
- **Action:** Server processes the submission:
  1. Validates PIN against active session
  2. Extracts face descriptor using face-api.js
  3. Checks for duplicate face descriptors
  4. Records attendance with timestamp
  5. Sends confirmation back to student
- **Output:** Attendance record saved to local database

## Flowchart Diagram
```
[●] Start
  |
  v
[Lecturer: Generate QR Code]
  |
  v
[Display QR on Screen]
  |
  v
[Student: Scan QR Code]
  |
  v
◇ QR Scan Successful?
  |Yes              |No
  v                 v
[Browser Opens]   [Enter URL Manually]
  |                 |
  +------+----------+
         |
         v
[Registration Form Loads]
  |
  v
[Student: Fill Form Fields]
  |
  v
[Student: Capture Face Image]
  |
  v
◇ Face Detected?
  |Yes              |No
  v                 v
[Submit Form]    [Retake Photo]
  |                 |
  |                 +---> (loop back)
  v
[Server: Validate PIN]
  |
  v
◇ PIN Valid?
  |Yes              |No
  v                 v
[Process Face]   [Error: Invalid PIN]
  |
  v
◇ Duplicate Face?
  |No               |Yes
  v                 v
[Save Record]    [Flag Duplicate]
  |                 |
  v                 v
[Show Success]   [Show Warning]
  |                 |
  +------+----------+
         |
         v
       [⊙] End
```

## Error Handling

| Error | Cause | Recovery |
|-------|-------|----------|
| QR scan fails | Camera blocked, poor lighting | Enter URL manually |
| Face not detected | No face in frame | Retake photo |
| Invalid PIN | Wrong code entered | Re-enter correct PIN |
| Duplicate face | Same face already registered | Flagged, lecturer decides |
| Server unreachable | Hotspot disconnected | Reconnect to Wi-Fi |

## Drawing Instructions
1. Use standard flowchart symbols (rectangles for processes, diamonds for decisions)
2. Flow top-to-bottom
3. Label all decision branches (Yes/No)
4. Show error paths branching off to the right
5. Use arrows to show flow direction
6. Color code: Green (success path), Red (error path), Blue (process)

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
