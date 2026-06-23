# Figure 4.5: Attendance Registration Activity Diagram

## Purpose
Describes the complete attendance registration workflow from session creation to dashboard update.

## Diagram Type
**UML Activity Diagram with Swimlanes**

## Swimlanes (Actors/Components)

| Lane | Actor/Component |
|------|-----------------|
| Lane 1 | Lecturer |
| Lane 2 | OwHAS Flutter App |
| Lane 3 | Node.js Server |
| Lane 4 | Student |

## Activity Flow

### Phase 1: Session Setup (Lecturer Lane)
```
[●] Start
  |
  v
[Create Session]
  - Select course from list
  - Set session duration
  - Configure geofence (optional)
  |
  v
[Generate QR Code & PIN]
  - 4-digit random PIN generated
  - QR code encodes server IP + PIN
  |
  v
[Start Hotspot & Server]
  - Enable Wi-Fi hotspot on device
  - Launch Node.js server on port 8080
  |
  v
[Display QR Code to Class]
  - Show QR on screen/projector
  - Announce PIN verbally
```

### Phase 2: Student Connection (Student Lane)
```
[Connect to Hotspot Wi-Fi]
  |
  v
◇ Decision: Captive Portal Detected?
  |Yes                    |No
  v                       v
[Auto-Open Browser]    [Scan QR Code]
  |                       |
  +--------> [Registration Page Opens] <-+
```

### Phase 3: Registration (Student + Server Lanes)
```
[Enter Session PIN]
  |
  v
◇ Decision: PIN Valid?
  |Yes              |No
  v                 v
[Continue]       [Show Error → Retry]
  |
  v
[Fill Registration Form]
  - Enter name
  - Enter matriculation number
  - Enter email (optional)
  |
  v
[Capture Face Image]
  - Front camera opens
  - Student takes selfie
  |
  v
◇ Decision: Face Detected?
  |Yes              |No
  v                 v
[Submit Form]    [Retry Capture]
  |
  v
[Server: Process Submission]
  |
  v
[Server: Run Face Verification]
  - Extract face descriptor (128-dim vector)
  - Compare with existing descriptors
  |
  v
◇ Decision: Duplicate Face?
  |No               |Yes
  v                 v
[Record Attendance] [Flag as Duplicate → Warn]
  |
  v
[Send Confirmation to Student]
```

### Phase 4: Dashboard Update (App Lane)
```
[Update Live Dashboard]
  - Increment attendee count
  - Add student to attendee list
  - Refresh statistics
  |
  v
◇ Decision: Session Ended?
  |No                |Yes
  v                  v
[Continue Accepting] [Lock Registration]
                       |
                       v
                     [Generate Reports]
                       |
                       v
                     [⊙] End
```

## Decision Points Summary

| Decision | Condition | Yes Path | No Path |
|----------|-----------|----------|---------|
| Captive portal detected? | Device auto-detects no internet | Auto-open browser | Student scans QR manually |
| PIN valid? | PIN matches active session | Continue registration | Show error, allow retry |
| Face detected? | face-api.js detects a face in image | Proceed to submission | Ask to retake photo |
| Duplicate face? | Face descriptor matches existing record | Flag and warn | Record attendance normally |
| Session ended? | Lecturer clicked "End" or timeout | Lock and generate report | Keep accepting students |

## Parallel Activities
- While students register (Phase 3), the dashboard updates in real-time (Phase 4)
- Multiple students can register simultaneously (concurrent)

## Drawing Instructions
1. Create 4 vertical swimlanes
2. Start with a filled circle (initial node) in the Lecturer lane
3. Flow downward through activities
4. Use diamonds for decision points with labeled branches
5. Use fork/join bars where activities happen in parallel
6. End with a bullseye (final node) in the App lane
7. Use arrows to show flow crossing lanes

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Visual Paradigm
- PlantUML
