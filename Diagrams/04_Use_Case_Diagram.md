# Diagram 04: Use Case Diagram - Lecturer & Student Interactions

## Purpose
Show all user interactions (use cases) with the OWHAS system from the perspective of different actors.

## Type
**UML Use Case Diagram**

## Actors

### 1. Lecturer
- Primary user
- Controls attendance sessions
- Generates reports

### 2. Student
- Primary user
- Registers attendance
- Provides biometric data

### 3. System (Node.js Server)
- Manages backend logic
- Validates data
- Stores records

### 4. Firebase Cloud
- External system
- Cloud storage and sync

### 5. Face-API.js
- External system
- Biometric verification

## Use Cases for Lecturer

| Use Case ID | Use Case Name | Description |
|-------------|---------------|-------------|
| UC-01 | Configure Session | Set course name, PIN, duration, max students |
| UC-02 | Start Attendance Session | Initiate session, generate PIN & QR code |
| UC-03 | Upload Previous Session | Import Excel/PDF to track cumulative attendance |
| UC-04 | Monitor Live Dashboard | View real-time attendee list, verification status |
| UC-05 | Remove Student | Delete attendee from records |
| UC-06 | End Session | Close attendance session |
| UC-07 | Generate Report | Create Excel/PDF attendance report |
| UC-08 | Register Student Manually | Bypass device fingerprint for discharged phones |
| UC-09 | Retry Server Connection | Re-detect server after network change |
| UC-10 | Sign In to Cloud | Firebase authentication for cloud sync |
| UC-11 | View Cloud Sessions | Browse previously synced sessions |
| UC-12 | Manage Course Catalogue | Add, edit, delete courses |
| UC-13 | Configure Signature | Set up digital signature for documents |

## Use Cases for Student

| Use Case ID | Use Case Name | Description |
|-------------|---------------|-------------|
| UC-14 | Enter Session PIN | Submit 4-digit PIN to verify session |
| UC-15 | Scan QR Code | Alternative to manual PIN entry |
| UC-16 | Capture Face | Take photo for biometric verification |
| UC-17 | Verify Face | System validates face against duplicates |
| UC-18 | Verify GPS Location | Confirm student is within geofence |
| UC-19 | Provide Digital Signature | Optional signature for record authentication |
| UC-20 | Receive Confirmation | See attendance recorded successfully |

## System-Level Use Cases

| Use Case ID | Use Case Name | Description |
|-------------|---------------|-------------|
| UC-21 | Validate PIN | Verify PIN matches session |
| UC-22 | Detect Duplicate Faces | Identify if same person registered twice |
| UC-23 | Validate Device Fingerprint | Check if device is allowed |
| UC-24 | Calculate GPS Distance | Determine if student is in geofence |
| UC-25 | Generate PDF Report | Create formatted PDF attendance sheet |
| UC-26 | Generate Excel Report | Create spreadsheet with attendance data |
| UC-27 | Sync to Firebase | Upload session data to cloud |
| UC-28 | Backup Records | Automatic backup of attendance data |

## Relationships to Show

### Include Relationships (required steps)
- UC-02 includes UC-01 (must configure before starting)
- UC-06 includes UC-07 (generate report when ending)
- UC-20 includes UC-25 or UC-26 (system generates report)

### Extend Relationships (optional steps)
- UC-08 extends UC-20 (manual registration alternative)
- UC-15 extends UC-14 (QR code alternative to PIN)
- UC-19 extends UC-20 (optional signature)

### Generalization
- Group lecturer use cases
- Group student use cases
- Group system use cases

## Visual Elements to Include
- Actors (stick figures or labeled boxes)
- Use cases (ovals with names)
- Relationships (solid lines for associations, arrows for includes/extends)
- System boundary (rectangle around use cases)
- Legend explaining line types

## Key Information to Display
- Actor names
- Use case names and IDs
- Relationship types
- System scope boundary

## Success Criteria
- All actors clearly identified
- All use cases visible and labeled
- Relationships correctly shown
- System boundary clear
- Easy to understand who does what

## Tools Suitable For
- Enterprise Architect
- Lucidchart
- Draw.io
- Visual Paradigm
- Astah

## Related Sections in Final_Doc
- Section 4.1: Use Case Diagram
- Section 6: User Workflows
