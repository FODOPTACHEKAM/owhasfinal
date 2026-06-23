# Figure 4.1: System Context Diagram

## Purpose
Shows the system boundary and external actors interacting with the OwHAS Hotspot Attendance System.

## Diagram Type
**Context Diagram (Level 0 DFD)**

## System
**OwHAS — Offline Wi-Fi Hotspot Attendance System**

## External Actors

### 1. Lecturer
- **Role:** Primary user who creates and manages attendance sessions
- **Interactions with System:**
  - Creates attendance sessions (course, PIN, duration)
  - Starts/stops the Node.js server and Wi-Fi hotspot
  - Monitors live attendance dashboard
  - Generates and exports attendance reports (PDF, Excel)
  - Syncs data to Firebase cloud

### 2. Student
- **Role:** End user who registers attendance
- **Interactions with System:**
  - Connects to lecturer's Wi-Fi hotspot
  - Enters 4-digit session PIN
  - Submits face image for anti-proxy verification
  - Provides GPS location (online mode)
  - Provides digital signature (optional)
  - Receives attendance confirmation

### 3. Firebase Cloud
- **Role:** External cloud backend for data persistence and authentication
- **Interactions with System:**
  - Receives synced attendance data from the app
  - Provides user authentication (email/password)
  - Stores session records, attendance records, and exported files
  - Enables cross-device data access

### 4. Node.js Server
- **Role:** Backend server running on the lecturer's device or cloud
- **Interactions with System:**
  - Hosts the captive portal registration page (hotspot.html)
  - Processes attendance submissions
  - Runs face-api.js for face recognition
  - Manages session state and attendee data
  - Serves as the bridge between student browsers and the Flutter app

## Data Flows (Inputs to System)

| From | Data | Description |
|------|------|-------------|
| Lecturer | Session configuration | Course, PIN, duration, geofence settings |
| Student | Attendance submission | Name, matric number, face image, PIN, GPS, signature |
| Firebase | Authentication tokens | User credentials and session tokens |
| Firebase | Stored records | Previously synced attendance data |

## Data Flows (Outputs from System)

| To | Data | Description |
|----|------|-------------|
| Lecturer | Live dashboard | Real-time attendee count and list |
| Lecturer | Reports | PDF and Excel attendance reports |
| Student | Confirmation | Attendance registration success/failure |
| Firebase | Synced data | Session records, attendance records, exported files |
| Node.js Server | Registration page | Captive portal HTML served to students |

## System Boundary
Everything inside the boundary:
- Flutter mobile application
- Local database (JSON/SQLite)
- Session management logic
- Face recognition processing
- Report generation engine
- Cloud sync service

Everything outside the boundary:
- Lecturer (human actor)
- Student (human actor)
- Firebase Cloud (external service)
- Wi-Fi network infrastructure

## Visual Layout Guide
```
                    [Lecturer]
                        |
            Session Config / Reports
                        |
                        v
[Firebase] <--sync--> [  OwHAS System  ] <--registration--> [Student]
                        |
                        v
                  [Node.js Server]
```

## Drawing Instructions
1. Draw OwHAS as a large central circle or rounded rectangle
2. Place Lecturer at the top, Student at the right
3. Place Firebase Cloud at the left, Node.js Server at the bottom
4. Draw labeled arrows showing data direction
5. Use a dashed boundary line around the system
6. Label all data flows clearly

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
