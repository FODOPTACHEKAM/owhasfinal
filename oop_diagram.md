# OOP Diagram Reference — OWHAS Attendance System

> **System:** OWHAS (Online / Wi-Fi Hotspot Attendance System)
> **Stack:** Flutter (mobile app) · Node.js + Express (local server) · Firebase (cloud)
> **Domain:** `owhas.org`

---

## 1. Use Case Diagram

### Title
**OWHAS — Biometric Attendance Registration System**

---

### Actors

| Actor | Type | Description |
|---|---|---|
| **Lecturer** | Primary | Creates and manages attendance sessions via the Flutter app |
| **Student** | Primary | Registers attendance via the web portal (hotspot.html) or the Flutter app |
| **Node.js Server** | System | Manages sessions, PIN validation, face verification, and GPS heartbeat |
| **Firebase Cloud** | External System | Stores sessions and attendance records for cloud-signed lecturers |
| **face-api.js** | External System | Client-side face detection and descriptor extraction |

---

### Use Cases by Actor

#### Lecturer
| ID | Use Case | Description |
|---|---|---|
| UC-01 | Configure Session | Set course name/code, grace period, duration, max students |
| UC-02 | Start Attendance Session | Generate 4-digit PIN + QR token, register session on server |
| UC-03 | Upload Previous Session | Import Excel/PDF to track cumulative attendance count |
| UC-04 | Monitor Live Dashboard | View real-time attendee list, verified/pending stats, Wi-Fi device count |
| UC-05 | Remove Student | Delete an attendee record from local storage and server |
| UC-06 | End Session & Export | Stop session, generate Excel report, sync to cloud |
| UC-07 | Export PDF Report | Download server-generated attendance PDF |
| UC-08 | Register Student Manually | Add a student bypassing device fingerprint check (discharged phone) |
| UC-09 | Retry Server Connection | Re-detect server IP and resync active session after network change |
| UC-10 | Sign In to Cloud | Firebase email/password login to enable cloud sync |
| UC-11 | View Cloud Sessions | Browse previously synced sessions from Firestore |
| UC-12 | Manage Course Catalogue | Add, edit, browse courses grouped by semester |
| UC-13 | Configure Signature | Set up digital signature for attendance sheets |

#### Student
| ID | Use Case | Description |
|---|---|---|
| UC-14 | Enter Session PIN | Submit 4-digit instructor PIN to verify session access |
| UC-15 | Capture Face Photo | Take selfie for biometric uniqueness check (anti-proxy) |
| UC-16 | Submit Registration Details | Enter full name, matricule, and email to register |
| UC-17 | View Registration Status | See confirmed name, course, and heartbeat status panel |
| UC-18 | GPS Heartbeat | Browser auto-sends location every 2 min to confirm presence |
| UC-19 | Scan QR Code | Open hotspot.html with session token pre-filled (skips PIN step) |
| UC-20 | Register via Flutter App | Direct student registration from within the Flutter app |

#### Node.js Server
| ID | Use Case | Description |
|---|---|---|
| UC-21 | Validate PIN | Check PIN against active sessions map |
| UC-22 | Verify Face Uniqueness | Compare face descriptor against all registered faces in session |
| UC-23 | Issue Heartbeat Token | Return one-time token used for GPS presence verification |
| UC-24 | Enforce Geofencing | Reject heartbeat if student >50 m from lecturer location |
| UC-25 | Auto-end Session | Timer deactivates PIN after `durationMinutes` |
| UC-26 | Persist Session to Disk | Save sessions.json on every write for crash recovery |

---

### Include / Extend Relationships

```
UC-02  <<include>>  UC-01        (session must be configured before start)
UC-15  <<include>>  UC-14        (face capture only after PIN verified)
UC-16  <<include>>  UC-15        (form only after face verified)
UC-18  <<extend>>   UC-16        (heartbeat only for online sessions)
UC-19  <<extend>>   UC-14        (QR token skips PIN step → extends registration flow)
UC-06  <<include>>  UC-05?       (optional: remove invalid students before ending)
UC-03  <<extend>>   UC-02        (upload is optional pre-session step)
UC-24  <<extend>>   UC-18        (geofence check extends every heartbeat)
```

---

## 2. Class Diagram

### Domain Models

```
┌─────────────────────────────────────────┐
│            AttendanceSession            │
├─────────────────────────────────────────┤
│ + id : String                           │
│ + courseName : String                   │
│ + courseCode : String?                  │
│ + lecturerId : String                   │
│ + lecturerName : String?                │
│ + sessionPin : String?                  │
│ + sessionToken : String?                │
│ + startTime : DateTime                  │
│ + endTime : DateTime?                   │
│ + durationMinutes : int                 │
│ + gracePeriodMinutes : int              │
│ + requiredConnectionMinutes : int       │
│ + maxAttendanceCount : int              │
│ + sessionNumber : int                   │
│ + isActive : bool                       │
│ + createdAt : DateTime                  │
│ + updatedAt : DateTime                  │
├─────────────────────────────────────────┤
│ + toJson() : Map                        │
│ + fromJson(json) : AttendanceSession    │
│ + copyWith(...) : AttendanceSession     │
└─────────────────────────────────────────┘
              1
              │ has many
              ▼
┌─────────────────────────────────────────┐
│            AttendanceRecord             │
├─────────────────────────────────────────┤
│ + id : String                           │
│ + sessionId : String                    │
│ + studentId : String                    │
│ + matricule : String                    │
│ + studentName : String                  │
│ + email : String?                       │
│ + joinedAt : DateTime                   │
│ + verifiedAt : DateTime?                │
│ + connectionDurationMinutes : int       │
│ + isVerified : bool                     │
│ + isManual : bool                       │
│ + deviceFingerprint : String            │
│ + location : AttendanceLocation?        │
│ + createdAt : DateTime                  │
│ + updatedAt : DateTime                  │
├─────────────────────────────────────────┤
│ + toJson() : Map                        │
│ + fromJson(json) : AttendanceRecord     │
│ + copyWith(...) : AttendanceRecord      │
└─────────────────────────────────────────┘
              │ has
              ▼
┌─────────────────────────────────────────┐
│          AttendanceLocation             │
├─────────────────────────────────────────┤
│ + latitude : double?                    │
│ + longitude : double?                   │
│ + accuracy : double?                    │
│ + address : String?                     │
│ + timestamp : DateTime?                 │
├─────────────────────────────────────────┤
│ + toJson() : Map                        │
│ + fromJson(json) : AttendanceLocation   │
│ + copyWith(...) : AttendanceLocation    │
└─────────────────────────────────────────┘

┌───────────────────────────┐
│          Student          │
├───────────────────────────┤
│ + id : String             │
│ + matricule : String      │
│ + name : String           │
│ + email : String?         │
│ + deviceFingerprint : String │
│ + createdAt : DateTime    │
│ + updatedAt : DateTime    │
├───────────────────────────┤
│ + toJson() : Map          │
│ + fromJson(json) : Student│
│ + copyWith(...) : Student │
└───────────────────────────┘

┌─────────────────────────────┐     ┌────────────────────────┐
│       CatalogueCourse       │     │        Semester        │
├─────────────────────────────┤     ├────────────────────────┤
│ + id : String               │     │ + id : String          │
│ + semesterId : String ──────┼────▶│ + label : String       │
│ + name : String             │     │ + academicYear : String│
│ + code : String             │     │ + number : int         │
│ + department : String?      │     │ + isActive : bool      │
│ + credits : int?            │     │ + createdAt : DateTime │
│ + createdAt : DateTime      │     └────────────────────────┘
└─────────────────────────────┘
```

---

### Service Layer (Singletons)

```
┌───────────────────────────────────────────────────────┐
│                     ServerConfig                      │
│                   <<singleton>>                       │
├───────────────────────────────────────────────────────┤
│ - _detectedUrl : String?                              │
│ - _isOnline : bool                                    │
│ - _isHybrid : bool                                    │
│ - _hasDetected : bool                                 │
│ + baseUrl : String          (get)                     │
│ + onlineUrl : String        (get) — https://owhas.org │
│ + onlineUrlHttp : String    (get) — http port 5501    │
│ + isOnline : bool           (get)                     │
│ + isHybrid : bool           (get)                     │
│ + emulatorUrl : String      (get)                     │
│ + hotspotUrl : String       (get)                     │
│ + baseQrUrl : String        (get)                     │
│ + subnet : String           (get)                     │
├───────────────────────────────────────────────────────┤
│ + detect() : Future<void>                             │
│ + getDynamicQrUrl() : Future<String>                  │
│ + reset() : void                                      │
└───────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────┐
│                    SessionService                     │
│                   <<singleton>>                       │
├───────────────────────────────────────────────────────┤
│ - _storage : StorageService                           │
│ - _deviceService : DeviceService                      │
│ - _cloudService : CloudService                        │
│ - _locationService : LocationService                  │
│ - _connectionTracker : Timer?                         │
│ - _autoEndTimer : Timer?                              │
│ - _studentJoinTimes : Map<String, DateTime>           │
├───────────────────────────────────────────────────────┤
│ + generateSessionPin() : String                       │
│ + generateSessionToken() : String                     │
│ + createSession(...) : Future<AttendanceSession>      │
│ + registerStudent(...) : Future<AttendanceRecord?>    │
│ + registerManualStudent(...) : Future<AttendanceRecord?> │
│ + endSession(sessionId) : Future<void>                │
│ + removeStudent(sessionId, recordId) : Future<void>   │
│ + resyncToServer() : Future<bool>                     │
│ + getSessionStats(sessionId) : Future<Map>            │
└───────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────┐
│                    StorageService                     │
│                   <<singleton>>                       │
├───────────────────────────────────────────────────────┤
│ - _prefs : SharedPreferences?                         │
├───────────────────────────────────────────────────────┤
│ + saveSession(session) : Future<void>                 │
│ + getSessions() : Future<List<AttendanceSession>>     │
│ + getActiveSession() : Future<AttendanceSession?>     │
│ + saveAttendanceRecord(record) : Future<void>         │
│ + getAttendanceRecords(sessionId) : Future<List>      │
│ + saveStudent(student, sessionId) : Future<void>      │
│ + getStudentByMatricule(m, sid) : Future<Student?>    │
│ + deleteAttendanceRecord(sid, rid) : Future<void>     │
│ + deleteStudent(studentId, sid) : Future<void>        │
│ + clearSessionData(sessionId) : Future<void>          │
└───────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────┐
│                     ApiService                        │
├───────────────────────────────────────────────────────┤
│ - _sessionPin : String?                               │
│ - _sessionToken : String?                             │
├───────────────────────────────────────────────────────┤
│ + pingServer() : Future<void>                         │
│ + fetchServerAttendees() : Future<List<Map>>          │
│ + fetchServerStats() : Future<Map>                    │
│ + fetchServerPdf() : Future<Uint8List?>               │
│ + registerStudentOnServer(...) : Future<void>         │
│ + resetServerSession(...) : Future<void>              │
│ + pushSessionConfig(...) : Future<void>               │
│ + removeAttendeeOnServer(matricule) : Future<void>    │
│ + verifySessionPin(pin) : Future<bool>                │
│ + parsePdfOnServer(bytes) : Future<Map>               │
│ + setSessionPin(pin) : void                           │
│ + setSessionToken(token) : void                       │
│ + clearSession() : void                               │
└───────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────┐
│                    CloudService                       │
│             <<singleton, Firebase>>                   │
├───────────────────────────────────────────────────────┤
│ - _initialized : bool                                 │
│ + currentUser : User?        (get)                    │
│ + isSignedIn : bool          (get)                    │
├───────────────────────────────────────────────────────┤
│ + initialize() : Future<void>                         │
│ + signIn(email, password) : Future<UserCredential>    │
│ + signUp(email, password, ...) : Future<UserCredential>│
│ + signOut() : Future<void>                            │
│ + syncSession(session) : Future<void>                 │
│ + syncAttendanceRecord(sid, record) : Future<void>    │
│ + fullSessionSync(session, records) : Future<void>    │
└───────────────────────────────────────────────────────┘
```

---

### Notifier Layer (ChangeNotifier / State Management)

```
┌────────────────────────────────────────────────────────┐
│               SessionStateNotifier                     │
│          <<ChangeNotifier, LoadingMixin>>              │
├────────────────────────────────────────────────────────┤
│ - _sessionService : SessionService                     │
│ - _storage : StorageService                            │
│ - _apiService : ApiService                             │
│ - _excelService : ExcelService                         │
│ - _faceService : FaceRecognitionService                │
│ - _activeSession : AttendanceSession?                  │
│ - _sessionNumber : int                                 │
│ - _serverWarning : String?                             │
│ - _previousAttendance : Map<String, int>               │
│ + activeSession : AttendanceSession?  (get)            │
│ + hasActiveSession : bool             (get)            │
│ + sessionNumber : int                 (get)            │
│ + serverWarning : String?             (get)            │
├────────────────────────────────────────────────────────┤
│ + initialize() : Future<void>                          │
│ + createSession(...) : Future<void>                    │
│ + uploadPreviousSession() : Future<bool>               │
│ + endSessionAndGenerateReport(...) : Future<String?>   │
│ + forceEndSession() : Future<void>                     │
│ + retryServerConnection() : Future<void>               │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│             AttendanceRecordNotifier                   │
│          <<ChangeNotifier, LoadingMixin>>              │
├────────────────────────────────────────────────────────┤
│ - _storage : StorageService                            │
│ - _apiService : ApiService                             │
│ - _sessionService : SessionService                     │
│ - _networkDiscovery : NetworkDiscoveryService          │
│ - _faceService : FaceRecognitionService                │
│ - _records : List<AttendanceRecord>                    │
│ - _serverStats : Map<String, dynamic>                  │
│ - _wifiDevices : int                                   │
│ + records : List<AttendanceRecord>    (get)            │
│ + activeWifiDevices : int             (get)            │
│ + serverStats : Map                   (get)            │
├────────────────────────────────────────────────────────┤
│ + refreshRecords(session) : Future<void>               │
│ + registerStudent(...) : Future<bool>                  │
│ + registerManualStudent(...) : Future<bool>            │
│ + removeStudent(recordId, session) : Future<bool>      │
│ + refreshWifiDeviceCount() : Future<void>              │
│ + getStats() : Map<String, int>                        │
│ + clear() : void                                       │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│              ServerStatusNotifier                      │
│              <<ChangeNotifier>>                        │
├────────────────────────────────────────────────────────┤
│ - _status : ServerConnectionStatus                     │
│ - _serverUrl : String                                  │
│ + status : ServerConnectionStatus    (get)             │
│ + serverUrl : String                 (get)             │
├────────────────────────────────────────────────────────┤
│ + initialize() : Future<void>                          │
│ + refresh() : Future<void>                             │
│ - _updateStatus() : Future<void>                       │
└────────────────────────────────────────────────────────┘

enum ServerConnectionStatus { checking, cloud, wifi, hybrid, none }
```

---

### Key Relationships Summary

```
SessionStateNotifier      ──uses──▶  SessionService
SessionStateNotifier      ──uses──▶  StorageService
SessionStateNotifier      ──uses──▶  ApiService
SessionStateNotifier      ──uses──▶  ExcelService
SessionStateNotifier      ──uses──▶  FaceRecognitionService

AttendanceRecordNotifier  ──uses──▶  StorageService
AttendanceRecordNotifier  ──uses──▶  ApiService
AttendanceRecordNotifier  ──uses──▶  SessionService
AttendanceRecordNotifier  ──uses──▶  NetworkDiscoveryService
AttendanceRecordNotifier  ──uses──▶  FaceRecognitionService

SessionService            ──uses──▶  StorageService
SessionService            ──uses──▶  CloudService
SessionService            ──uses──▶  LocationService
SessionService            ──uses──▶  DeviceService

ServerStatusNotifier      ──reads─▶  ServerConfig
ApiService                ──reads─▶  ServerConfig  (baseUrl)

AttendanceSession         ──1:N──▶  AttendanceRecord
AttendanceRecord          ──1:1──▶  AttendanceLocation
CatalogueCourse           ──N:1──▶  Semester
```

---

## 3. Sequence Diagrams

---

### SD-1 — App Startup: Server Auto-Detection

```
Flutter App          ServerConfig          compute isolate        ServerStatusNotifier
     │                    │                      │                        │
     │── detect() ───────▶│                      │                        │
     │                    │── compute(fn) ───────▶│                       │
     │                    │                      │── cloud probe ──▶ owhas.org
     │                    │                      │    (parallel)           │
     │                    │                      │── local scan ──▶ 192.168.x.x:5501
     │                    │                      │    (800 ms timeout)     │
     │                    │                      │◀── both respond         │
     │                    │                      │── _ServerDetectionResult│
     │                    │                      │   (isHybrid=true)       │
     │                    │◀── result ───────────│                        │
     │                    │ _isHybrid=true        │                        │
     │                    │ _detectedUrl=localIP  │                        │
     │◀── detect done ────│                      │                        │
     │── initialize() ────────────────────────────────────────────────────▶│
     │                                                                     │
     │                                                           _updateStatus()
     │                                                     pingServer() ──▶ server
     │                                                     isHybrid=true
     │                                                     _status = hybrid
     │                                                     notifyListeners()
     │                                                                     │
     │◀──────── UI updates banner: purple "Hybrid Network" ───────────────│
```

---

### SD-2 — Lecturer Creates an Attendance Session

```
Lecturer    SessionSetupScreen    SessionStateNotifier    SessionService    Node.js Server    StorageService    CloudService
   │               │                      │                    │                 │                 │                │
   │──fill form──▶│                      │                    │                 │                 │                │
   │──tap Start──▶│                      │                    │                 │                 │                │
   │              │── createSession() ──▶│                    │                 │                 │                │
   │              │                      │── createSession() ─▶│                │                 │                │
   │              │                      │                    │── generatePin() │                 │                │
   │              │                      │                    │── generateToken()                 │                │
   │              │                      │                    │── LocationService.collect()        │                │
   │              │                      │                    │── POST /api/session-init ─────────▶│               │
   │              │                      │                    │◀─ 200 OK ─────────────────────────│               │
   │              │                      │                    │── saveSession() ──────────────────────────────────▶│
   │              │                      │                    │◀─ saved ──────────────────────────────────────────│
   │              │                      │                    │── syncSession() ───────────────────────────────────────────▶│
   │              │                      │◀── session ────────│                 │                 │                │
   │              │                      │── pushSessionConfig()── POST /api/session-config ──────▶│               │
   │              │◀── notifyListeners()─│                    │                 │                 │                │
   │◀─ dashboard──│                      │                    │                 │                 │                │
```

---

### SD-3 — Student Registers via Web Portal (hotspot.html)

```
Student Browser     hotspot.html JS       Node.js Server         face-api.js
      │                   │                     │                     │
      │── open URL ──────▶│                     │                     │
      │                   │── GET /ping ────────▶│                    │
      │                   │◀── 200 OK ──────────│                     │
      │── enter PIN ─────▶│                     │                     │
      │                   │── POST /api/validate-pin ───────────────▶│
      │                   │◀── 200 {courseName, lecturerName} ───────│
      │◀─ face step shown─│                     │                     │
      │── take photo ────▶│                     │                     │
      │                   │── detectSingleFace() ────────────────────▶│
      │                   │◀── descriptor[128] ─────────────────────│
      │                   │── POST /api/verify-face ────────────────▶│
      │                   │         {descriptor, pin}                 │
      │                   │◀── 200 {unique:true, faceId:"uuid"} ────│
      │◀─ form step shown─│                     │                     │
      │── fill details ──▶│                     │                     │
      │── submit ────────▶│                     │                     │
      │                   │── navigator.geolocation.getCurrentPosition()
      │                   │── POST /api/biometric-connect ──────────▶│
      │                   │         {username, matricule, email,      │
      │                   │          faceId, lat, lng, pin}           │
      │                   │◀── 200 {heartbeatToken, intervalMs} ────│
      │◀─ success shown ──│                     │                     │
      │                   │── localStorage.setItem('owhas_reg', ...) │
      │                   │── setInterval(heartbeat, 2 min)           │
      │                   │                     │                     │
      │                (every 2 min)            │                     │
      │                   │── POST /api/heartbeat ──────────────────▶│
      │                   │         {token, matricule, lat, lng}      │
      │                   │◀── 200 OK  (or 403 if out of range) ────│
```

---

### SD-4 — Lecturer Views Live Dashboard & Removes a Student

```
Lecturer    LecturerDashboard    AttendanceRecordNotifier    ApiService    Node.js    StorageService
   │               │                       │                     │            │             │
   │── open ──────▶│                       │                     │            │             │
   │               │── refreshRecords() ──▶│                     │            │             │
   │               │                       │── getAttendanceRecords() ────────────────────▶│
   │               │                       │◀─ local records ─────────────────────────────│
   │               │                       │── fetchServerAttendees() ───────▶│            │
   │               │                       │◀─ [{matricule, username, ...}] ──│            │
   │               │                       │── merge (server wins) │           │            │
   │               │◀── notifyListeners() ─│                     │            │             │
   │◀─ list shown ─│                       │                     │            │             │
   │               │                       │                     │            │             │
   │── tap Remove ▶│                       │                     │            │             │
   │               │── removeStudent() ───▶│                     │            │             │
   │               │                       │── SessionService.removeStudent() ────────────▶│
   │               │                       │◀─ deleted ───────────────────────────────────│
   │               │                       │── FaceService.removeFace()        │            │
   │               │                       │── removeAttendeeOnServer() ────── ▶│           │
   │               │                       │◀─ 200 OK ───────────────────────▶│            │
   │               │◀── notifyListeners() ─│                     │            │             │
   │◀─ list updated│                       │                     │            │             │
```

---

### SD-5 — End Session & Generate Excel Report

```
Lecturer    Dashboard    SessionStateNotifier    ExcelService    SessionService    StorageService    CloudService
   │            │                │                    │                │                 │                │
   │── End ────▶│                │                    │                │                 │                │
   │            │── endSession()▶│                    │                │                 │                │
   │            │                │── generateReport() ▶│               │                 │                │
   │            │                │                    │── write xlsx   │                 │                │
   │            │                │◀── filePath ───────│                │                 │                │
   │            │                │── _teardown()      │                │                 │                │
   │            │                │──────────────────────────────────── endSession() ───▶│                │
   │            │                │                    │                │── copyWith(isActive=false)       │
   │            │                │                    │                │── saveSession() ─────────────────▶│
   │            │                │                    │                │── POST /api/end-session           │
   │            │                │──────────────────────────────────── clearSessionData() ───────────────▶│
   │            │                │── FaceService.clearSession()        │                 │                │
   │            │                │── ApiService.clearSession()         │                 │                │
   │            │                │──────────────────────────────────────────────────── fullSessionSync() ▶│
   │            │◀─ notifyListeners()                 │                │                 │                │
   │◀─ setup screen shown        │                    │                │                 │                │
```

---

## 4. Product Backlog

### Backlog Table

| ID | User Story | Priority | Story Points | Status |
|---|---|---|---|---|
| PB-001 | As a **Lecturer**, I want to create an attendance session with a course name, PIN, grace period, and duration so that students can register. | Must Have | 8 | Done |
| PB-002 | As a **Student**, I want to enter a 4-digit PIN in the browser to verify I am in the correct class. | Must Have | 5 | Done |
| PB-003 | As a **Student**, I want to take a selfie so the system can confirm I am not registering for another student (anti-proxy). | Must Have | 13 | Done |
| PB-004 | As a **Student**, I want to submit my full name, matricule, and email to complete attendance registration. | Must Have | 3 | Done |
| PB-005 | As a **Student**, I want the page to keep confirming my presence automatically every 2 minutes via GPS so I do not have to do anything extra. | Must Have | 8 | Done |
| PB-006 | As a **Lecturer**, I want to see a live dashboard with names, verification status, and connection duration updated in real time. | Must Have | 8 | Done |
| PB-007 | As a **Lecturer**, I want to end a session and automatically generate an Excel attendance report saved to my device. | Must Have | 8 | Done |
| PB-008 | As a **Lecturer**, I want the Flutter app to auto-detect the server IP (hotspot, VLAN, or cloud) so I do not have to configure anything manually. | Must Have | 13 | Done |
| PB-009 | As a **Lecturer**, I want a QR code students can scan to open the registration page without typing a URL. | Should Have | 5 | Done |
| PB-010 | As a **Lecturer**, I want to manually add a student with a discharged phone so they are not excluded from attendance. | Should Have | 3 | Done |
| PB-011 | As a **Lecturer**, I want to upload the previous session's Excel/PDF file so the system tracks cumulative attendance across sessions. | Should Have | 8 | Done |
| PB-012 | As a **Lecturer**, I want to sign in with my institutional email to sync sessions and attendance records to the cloud (Firebase) for backup and remote viewing. | Should Have | 13 | Done |
| PB-013 | As a **Lecturer**, I want the system to detect if a student has left the classroom radius (>50 m) and freeze their attendance clock automatically. | Should Have | 8 | Done |
| PB-014 | As a **Lecturer**, I want to manage a course catalogue organised by semester so I can quickly pick a course when starting a session. | Should Have | 5 | Done |
| PB-015 | As a **System**, I want to fingerprint each device so one phone cannot register two different students in the same session. | Must Have | 5 | Done |
| PB-016 | As a **Lecturer**, I want the server to block more than 10 PIN attempts per device per 5 minutes to prevent brute-force access. | Must Have | 3 | Done |
| PB-017 | As a **Lecturer**, I want to export a PDF attendance sheet directly from the server without needing the Flutter app. | Could Have | 5 | Done |
| PB-018 | As a **Student**, I want the registration page to remember I already registered, so I do not see the PIN form again if I accidentally reload. | Should Have | 3 | Done |
| PB-019 | As a **Lecturer**, I want the app status bar to show a purple "Hybrid" indicator when both the local server and internet are reachable simultaneously (VLAN + cloud). | Could Have | 3 | Done |
| PB-020 | As a **Lecturer**, I want to configure a digital signature that appears on printed attendance sheets for official records. | Could Have | 5 | Done |
| PB-021 | As a **Lecturer**, I want to view previous sessions stored in the cloud and browse their attendance lists from any device. | Could Have | 8 | Done |
| PB-022 | As a **Lecturer**, I want the system to scan the Wi-Fi network and display how many devices are currently connected so I can cross-check with registrations. | Could Have | 5 | Done |
| PB-023 | As a **System**, I want sessions to auto-end after the configured duration so the lecturer does not have to remember to stop them manually. | Should Have | 3 | Done |
| PB-024 | As a **Lecturer**, I want a Retry button in the dashboard to reconnect and resync the active session to the server after a network interruption without losing existing records. | Should Have | 5 | Done |

---

### Backlog Priority Legend

| Priority | MoSCoW | Meaning |
|---|---|---|
| Must Have | M | Core — system cannot function without it |
| Should Have | S | Important — high value, no workaround |
| Could Have | C | Nice to have — add if time permits |
| Won't Have | W | Deferred to future release |

---

### Sprint Grouping (Suggested)

| Sprint | Items | Theme |
|---|---|---|
| Sprint 1 | PB-001, PB-002, PB-004, PB-008, PB-015 | Core session + registration flow |
| Sprint 2 | PB-003, PB-005, PB-013, PB-016 | Biometric + GPS presence enforcement |
| Sprint 3 | PB-006, PB-007, PB-010, PB-023, PB-024 | Dashboard, reporting, session lifecycle |
| Sprint 4 | PB-009, PB-011, PB-014, PB-017 | QR, catalogue, cumulative tracking, export |
| Sprint 5 | PB-012, PB-018, PB-019, PB-020, PB-021, PB-022 | Cloud sync, UX polish, hybrid network, signature |
