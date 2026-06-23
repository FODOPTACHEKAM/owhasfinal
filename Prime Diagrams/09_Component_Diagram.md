# Figure 4.9: Component Diagram

## Purpose
Shows the software components of OwHAS and their dependencies.

## Diagram Type
**UML Component Diagram**

## Components

### 1. UI Module
- **Package:** `lib/pages/`
- **Responsibility:** All user interface screens and widgets
- **Sub-components:**
  - LoginPage — Firebase authentication screen
  - SessionPage — Session creation and configuration
  - DashboardPage — Live attendance monitoring
  - ReportPage — Report viewing and export
  - SettingsPage — App configuration
- **Provided Interface:** User interaction screens
- **Required Interface:** SessionModule, AttendanceModule, AuthModule

### 2. Session Module
- **Package:** `lib/services/session_service.dart`
- **Responsibility:** Session lifecycle management
- **Sub-components:**
  - SessionCreator — Create new sessions with PIN and config
  - SessionManager — Start, pause, end sessions
  - SessionStorage — Persist session data locally
- **Provided Interface:** ISessionService (create, start, end, getSession)
- **Required Interface:** StorageModule, AttendanceModule

### 3. QR Module
- **Package:** `lib/services/` + `backend/`
- **Responsibility:** QR code generation and processing
- **Sub-components:**
  - QRGenerator — Create QR codes with session info
  - QRScanner — Decode scanned QR codes
  - QRDisplay — Show QR on lecturer's screen
- **Provided Interface:** IQRService (generate, scan, display)
- **Required Interface:** SessionModule (for session data)

### 4. Attendance Module
- **Package:** `lib/services/attendance_service.dart` + `backend/server.js`
- **Responsibility:** Core attendance registration and tracking
- **Sub-components:**
  - RegistrationHandler — Process student submissions
  - DuplicateChecker — Detect duplicate registrations
  - AttendeeTracker — Maintain live attendee list
  - DeviceFingerprinter — Identify unique devices
- **Provided Interface:** IAttendanceService (register, getAttendees, checkDuplicate)
- **Required Interface:** FaceModule, StorageModule, SessionModule

### 5. Face Recognition Module
- **Package:** `backend/` (face-api.js)
- **Responsibility:** Face detection, descriptor extraction, and comparison
- **Sub-components:**
  - FaceDetector — Detect faces in images using 5 face-api models
  - DescriptorExtractor — Generate 128-dim face embeddings
  - FaceComparator — Compare descriptors (threshold: 0.45)
  - ModelLoader — Load and cache face-api neural network models
- **Provided Interface:** IFaceService (detect, extract, compare)
- **Required Interface:** face-api.js library, model files

### 6. Export Module
- **Package:** `lib/services/`
- **Responsibility:** Generate attendance reports
- **Sub-components:**
  - PDFGenerator — Create PDF attendance reports
  - ExcelGenerator — Create Excel spreadsheets
  - FileManager — Save files to device storage
- **Provided Interface:** IExportService (generatePDF, generateExcel, saveFile)
- **Required Interface:** SessionModule, AttendanceModule, StorageModule

### 7. Firebase Module
- **Package:** `lib/services/`
- **Responsibility:** Cloud integration and synchronization
- **Sub-components:**
  - AuthService — Firebase email/password authentication
  - FirestoreSync — Upload/download session and attendance data
  - CloudStorage — Upload exported reports
  - ConnectivityChecker — Monitor internet availability
- **Provided Interface:** ICloudService (auth, sync, upload, checkConnectivity)
- **Required Interface:** Firebase SDK, Internet connectivity

### 8. Storage Module
- **Package:** `lib/services/` + local file system
- **Responsibility:** Local data persistence
- **Sub-components:**
  - LocalDatabase — JSON file-based storage
  - SharedPreferences — App settings storage
  - FileStorage — Report files, face images
  - CacheManager — Temporary data caching
- **Provided Interface:** IStorageService (read, write, delete, query)
- **Required Interface:** Device file system access

## Dependency Map

```
[UI Module]
    |
    +---depends on--→ [Session Module]
    +---depends on--→ [Attendance Module]
    +---depends on--→ [Export Module]
    +---depends on--→ [Firebase Module]
    +---depends on--→ [QR Module]

[Attendance Module]
    +---depends on--→ [Face Recognition Module]
    +---depends on--→ [Storage Module]
    +---depends on--→ [Session Module]

[Session Module]
    +---depends on--→ [Storage Module]

[Export Module]
    +---depends on--→ [Session Module]
    +---depends on--→ [Attendance Module]
    +---depends on--→ [Storage Module]

[Firebase Module]
    +---depends on--→ [Storage Module] (for offline cache)

[QR Module]
    +---depends on--→ [Session Module]
```

## Drawing Instructions
1. Draw each component as a rectangle with the UML component icon (two small rectangles)
2. Show provided interfaces as lollipops (circles) on the component
3. Show required interfaces as sockets (half-circles)
4. Connect sockets to lollipops to show dependencies
5. Group related components visually
6. Label all interfaces and dependencies

## Tools
- Draw.io / diagrams.net
- Lucidchart
- StarUML
- Visual Paradigm
- PlantUML
