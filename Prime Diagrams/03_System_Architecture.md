# Figure 4.3: Overall System Architecture

## Purpose
Presents the complete architecture of OwHAS showing all layers and their interactions.

## Diagram Type
**Layered System Architecture Diagram**

## Architecture Layers

### Layer 1: Presentation Layer (UI)
- **Technology:** Flutter (Dart)
- **Components:**
  - Login / Registration Screens
  - Session Configuration Page
  - Live Attendance Dashboard
  - Report Generation Page
  - QR Code Display/Scanner
  - Settings & Profile Pages
- **Responsibility:** User interaction, input validation, navigation

### Layer 2: State Management Layer
- **Technology:** Flutter setState / Provider
- **Components:**
  - Session State Management
  - Authentication State
  - Server Connection State
  - Attendance List State
  - UI Refresh Controllers
- **Responsibility:** Managing reactive UI state, notifying widgets of changes

### Layer 3: Service Layer (Business Logic)
- **Technology:** Dart services + Node.js backend
- **Components:**
  - SessionService — create, start, end sessions
  - AttendanceService — register, verify, count attendees
  - FaceRecognitionService — capture, compare, duplicate detection
  - GPSService — geofence verification, location tracking
  - ReportService — PDF and Excel generation
  - ServerConfigService — server auto-detection, connection management
  - CloudSyncService — Firebase upload/download
  - AuthService — Firebase authentication
- **Responsibility:** Core business logic, API communication, data processing

### Layer 4: Data Layer (Local Storage)
- **Technology:** JSON files, SharedPreferences, local file system
- **Components:**
  - Local Session Database (JSON)
  - Attendance Records Storage
  - Face Descriptor Cache
  - Report File Storage (PDF/Excel)
  - App Configuration Storage
- **Responsibility:** Offline data persistence, caching, file management

### Layer 5: Firebase Cloud Layer
- **Technology:** Firebase (Google Cloud)
- **Components:**
  - Firebase Authentication — user login/signup
  - Cloud Firestore — document database for sessions and records
  - Firebase Storage — file storage for reports and face images
  - Cloud Functions — server-side processing (optional)
- **Responsibility:** Cloud backup, cross-device sync, user authentication

## Cross-Cutting Concerns
- **Networking:** HTTP client for server communication, Firebase SDK for cloud
- **Security:** PIN validation, face recognition, device fingerprinting, GPS verification
- **Error Handling:** Network errors, server unavailability, camera failures
- **Logging:** Activity logging for debugging and audit

## Data Flow
```
[UI Layer]
    ↕ (User input / UI updates)
[State Management]
    ↕ (State changes / Events)
[Service Layer]
    ↕ (API calls / Business logic)
[Data Layer] ←→ [Firebase Cloud]
    (Local storage)    (Cloud sync)
```

## Drawing Instructions
1. Stack 5 layers vertically (Layer 1 on top, Layer 5 at bottom)
2. Label each layer with its name and technology
3. List key components inside each layer
4. Draw bidirectional arrows between adjacent layers
5. Show Firebase Cloud as a separate block connected to the Data Layer
6. Use color coding: Blue (UI), Green (State), Orange (Service), Purple (Data), Red (Cloud)

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
- Figma
