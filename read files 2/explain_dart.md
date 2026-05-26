# OwHAS Flutter — Dart File Reference

Every `.dart` file in `lib/` is listed below, grouped by architectural layer, with its full path, role, and how it connects to the rest of the app.

---

## Root Files (`lib/`)

### `lib/main.dart`
**Role:** App entry point and dependency-injection root.

On launch it runs three parallel async tasks — `CourseService.seedFromManagement()`, `ServerConfig().detect()`, and `CloudService().initialize()` — alongside a 2-second minimum splash delay. After all four futures resolve, it calls `runApp(MyApp())`.

`MyApp` builds a `MultiProvider` tree that makes the four shared notifiers (`SessionStateNotifier`, `AttendanceRecordNotifier`, `ReportNotifier`, `ServerStatusNotifier`) available to the entire widget tree. Shared service instances (`ApiService`, `NetworkDiscoveryService`, `FileService`) are created once here in `_SharedServices` so all notifiers see the same in-memory state (e.g. the same session PIN token stored on `ApiService`).

---

### `lib/nav.dart`
**Role:** Routing configuration (GoRouter).

Declares the `AppRouter` class that holds the `GoRouter` singleton and maps URL paths to screen widgets. Also declares `AppRoutes`, a static constants class with the 8 route paths (`/`, `/setup`, `/dashboard`, `/register`, `/signature`, `/cloud-login`, `/cloud-sessions`, `/catalogue`). All navigation in the app uses these constants.

---

### `lib/theme.dart`
**Role:** Global visual design tokens and Material 3 themes.

Contains:
- `AppSpacing` — pixel spacing constants (`xs` → `xxl`) and pre-built `EdgeInsets`.
- `AppRadius` — border-radius constants (`sm` → `xl`).
- `LightModeColors` / `DarkModeColors` — full Material 3 color palettes.
- `FontSizes` — named font-size constants matching Material 3 type scale.
- `lightTheme` / `darkTheme` getters — fully configured `ThemeData` objects using the Inter font family.
- Text-style extensions (`bold`, `semiBold`, etc.) on `TextStyle` and `BuildContext`.

---

### `lib/firebase_options.dart`
**Role:** Auto-generated Firebase configuration (created by the FlutterFire CLI).

Provides `DefaultFirebaseOptions.currentPlatform` which returns the correct `FirebaseOptions` for the current platform (web, iOS, macOS, Windows). Android and Linux are not configured. Never edit this file manually — regenerate it with `flutterfire configure`.

---

### `lib/course_management.dart`
**Role:** Static institution course catalogue — the one file an IT admin edits before building the APK.

Contains `CourseManagement` with three fields: `institutionName`, `version` (a string that triggers a device catalogue refresh when changed), and `semesters` (the full list of `SemesterData` → `CourseData` objects for the institution). On every app launch, `CourseService.seedFromManagement()` checks this version against the stored one; if different, it wipes and rebuilds the local catalogue from this data.

---

## Core Layer (`lib/core/`)

### `lib/core/abstractions/base_cloud_service.dart`
**Role:** Abstract contract for cloud sync.

Defines `BaseCloudService` with three methods: `syncSession`, `syncAttendanceRecord`, and `fullSessionSync`. The key design rule documented here is that all callers must check `isSignedIn` first and must never let a cloud failure block core attendance functionality.

---

### `lib/core/abstractions/base_face_recognition_service.dart`
**Role:** Abstract contract for the face recognition service.

Defines the interface (detect, store, findDuplicate, clear) without binding to the ML Kit implementation. Allows swapping the recognition back-end in tests or future versions.

---

### `lib/core/abstractions/base_report_service.dart`
**Role:** Abstract contract for PDF report generation.

Defines the interface for generating and sharing attendance PDF reports.

---

### `lib/core/abstractions/base_session_service.dart`
**Role:** Abstract contract for session lifecycle management.

Defines the core session operations: create, register student, end session, and get stats.

---

### `lib/core/abstractions/base_storage_service.dart`
**Role:** Abstract contract for local persistence.

Defines the read/write interface for sessions, attendance records, and students. The concrete implementation is `StorageService` (SharedPreferences).

---

### `lib/core/abstractions/base_api_service.dart`
**Role:** Abstract contract for Node.js server communication.

Defines the HTTP operations the app performs against the backend (ping, register student, fetch attendees, fetch stats, reset session, etc.).

---

### `lib/core/constants/route_constants.dart`
**Role:** Typed route path constants.

`RouteConstants` is a non-instantiable class with 8 static `String` constants for every GoRouter path. Screens use these instead of raw strings so a path rename is a single-point change.

---

### `lib/core/extensions/context_extensions.dart`
**Role:** Convenience extensions on `BuildContext`.

Adds `navigateTo(route)` and similar helpers so screens can navigate without boilerplate `GoRouter.of(context).go(...)` calls.

---

### `lib/core/extensions/datetime_extensions.dart`
**Role:** Convenience extensions on `DateTime`.

Adds formatting helpers (e.g. `toReadableString()`) used by screens and PDF generation to display dates consistently.

---

### `lib/core/mixins/loading_mixin.dart`
**Role:** Reusable `isLoading` / `error` state for `ChangeNotifier` subclasses.

`LoadingMixin` adds `_isLoading`, `_error`, and the `runWithLoading(() => ...)` wrapper that flips the loading flag, catches exceptions into `_error`, and calls `notifyListeners()`. All three notifiers (`SessionStateNotifier`, `AttendanceRecordNotifier`, `ReportNotifier`) mix this in instead of duplicating the same boilerplate.

---

### `lib/core/mixins/snackbar_mixin.dart`
**Role:** Reusable snackbar display helper for `State` subclasses.

Adds `showSuccess(message)` and `showError(message)` so screens don't repeat `ScaffoldMessenger.of(context).showSnackBar(...)` everywhere.

---

## Features — Home (`lib/features/home/`)

### `lib/features/home/screens/home_screen.dart`
**Role:** Landing screen with role-selection UI.

Shows two cards — "Lecturer" and "Student" — with an animated entrance. Tapping "Lecturer" either navigates to the session setup screen or shows a dialog offering to go to the active session dashboard. Tapping "Student" navigates to the student registration screen. Reads `SessionStateNotifier` to know if a session is already running.

---

### `lib/features/home/notifiers/server_status_notifier.dart`
**Role:** Provider notifier for the server connection indicator on the home screen.

Exposes `status` (an enum: `checking`, `cloud`, `wifi`, `hybrid`, `none`) and `serverUrl`. On `initialize()` it calls `ApiService().pingServer()` and reads the flags already computed by `ServerConfig`; on failure it tries the cloud URL directly. Exposes `refresh()` which resets `ServerConfig` and re-probes, used by the "Refresh GPS / server" button.

---

### `lib/features/home/widgets/home_animations.dart`
**Role:** Shared animation controllers and tweens for the home screen entrance effects.

---

### `lib/features/home/widgets/home_ui_components.dart`
**Role:** The server-status banner, connection chip, and other static UI pieces rendered at the top of the home screen.

---

### `lib/features/home/widgets/role_card.dart`
**Role:** The tappable card widget for each user role (Lecturer / Student) shown on the home screen.

---

## Features — Session (`lib/features/session/`)

### `lib/features/session/screens/session_setup_screen.dart`
**Role:** Form screen where the lecturer configures and launches a new attendance session.

Fields include lecturer name, semester picker, course picker (from the local catalogue), grace period, required connection minutes, max attendance count, and session duration. Also allows uploading a previous session's Excel/PDF to carry forward cumulative attendance marks. On submit it calls `SessionStateNotifier.createSession(...)`.

---

### `lib/features/session/screens/lecturer_dashboard_screen.dart`
**Role:** Live session dashboard for the lecturer.

Auto-refreshes every 5 seconds via a `Timer`. Displays the QR code, session stats (total / verified / pending), the Wi-Fi device count, and the full list of registered students. Lets the lecturer end the session, generate the PDF report, and remove individual students. Reads all three notifiers (`SessionStateNotifier`, `AttendanceRecordNotifier`, `ReportNotifier`).

---

### `lib/features/session/notifiers/session_state_notifier.dart`
**Role:** Provider notifier that owns the session lifecycle.

Responsibilities: initialize (restore active session from storage on startup, auto-end if expired), create a session (delegates to `SessionService`, syncs to Firebase, sets the PIN on `ApiService`), upload previous session file for cumulative attendance, end session (delegates to `SessionService`, clears `ApiService` state, clears face descriptors). Exposes `activeSession`, `sessionNumber`, `previousAttendance`, `serverWarning`, `hasActiveSession`.

---

### `lib/features/session/widgets/course_picker_section.dart`
**Role:** Semester + course dropdown widget used inside the session setup form.

---

### `lib/features/session/widgets/dashboard_app_bar.dart`
**Role:** Custom app bar for the lecturer dashboard with session title and action buttons.

---

### `lib/features/session/widgets/dashboard_body.dart`
**Role:** Main body of the lecturer dashboard that composes `SessionHeader`, `QrCodeSection`, `AttendanceRecordsSection`, and the compact stat chips.

---

### `lib/features/session/widgets/session_form_fields.dart`
**Role:** Lecturer name and general input fields for the session setup form.

---

### `lib/features/session/widgets/timing_fields_section.dart`
**Role:** Grace period, required connection time, max attendance, and duration input widgets in the session setup form.

---

## Features — Attendance (`lib/features/attendance/`)

### `lib/features/attendance/screens/student_registration_screen.dart`
**Role:** Multi-step self-registration screen for students.

Steps: (1) PIN entry — student types the 4-digit PIN shown on the classroom poster; (2) Details entry — matricule, name, optional email; (3) Face capture — opens `FaceCapturePage`, runs duplicate-face check, then registers. After successful registration it shows `SuccessDialog`. Reads `SessionStateNotifier` and `AttendanceRecordNotifier`.

---

### `lib/features/attendance/notifiers/attendance_record_notifier.dart`
**Role:** Provider notifier that owns the attendance record list for the active session.

Exposes `records` (merged from local storage and live server), `serverStats`, `activeWifiDevices`, `wifiDeviceIps`. Key method `refreshRecords(session)` fetches local records and server attendees in parallel and merges them (server wins on conflict). Also handles manual student registration, removing a student (calls `SessionService.removeStudent` which also hits the server), Wi-Fi device scan, and face-based duplicate checks.

---

### `lib/features/attendance/widgets/registration_card.dart`
**Role:** Card container widget wrapping each step of the student registration form.

---

### `lib/features/attendance/widgets/registration_steps.dart`
**Role:** Step indicator (PIN → Details → Face) shown at the top of the registration screen.

---

### `lib/features/attendance/widgets/registration_widgets.dart`
**Role:** Individual input widgets for the registration steps (PIN field, matricule field, name field, email field).

---

### `lib/features/attendance/widgets/success_dialog.dart`
**Role:** Modal dialog shown after successful student registration, confirming the student's name and matricule.

---

## Features — Catalogue (`lib/features/catalogue/`)

### `lib/features/catalogue/screens/course_catalogue_screen.dart`
**Role:** Read-only catalogue screen that shows all semesters and their courses.

Loaded from `CourseService`; supports adding, editing, and deleting courses and semesters via dialogs. Changes persist to SharedPreferences through `CourseService`.

---

### `lib/features/catalogue/widgets/catalogue_dialogs.dart`
**Role:** Add-course and add-semester dialog widgets used by the catalogue screen.

---

### `lib/features/catalogue/widgets/catalogue_empty_state.dart`
**Role:** Empty-state illustration and message shown when no semesters or courses exist in the catalogue.

---

### `lib/features/catalogue/widgets/catalogue_tiles.dart`
**Role:** `ExpansionTile` widgets for each semester and `ListTile` for each course inside the catalogue screen.

---

## Features — Cloud (`lib/features/cloud/`)

### `lib/features/cloud/screens/cloud_login_screen.dart`
**Role:** Firebase authentication screen for lecturers.

Supports both sign-in and sign-up (toggled by a link). On sign-up it collects display name and department. On success it navigates to the cloud sessions screen. Delegates to `CloudService`.

---

### `lib/features/cloud/screens/cloud_sessions_screen.dart`
**Role:** Lists all past attendance sessions stored in Firestore for the logged-in lecturer.

Loads sessions via `CloudService.fetchSessions()`. Each session card shows course name, date, attendee count, and a download button that fetches the records from Firestore and generates a local PDF.

---

### `lib/features/cloud/widgets/cloud_login_form.dart`
**Role:** The actual form fields (email, password, name, department) rendered inside `CloudLoginScreen`.

---

### `lib/features/cloud/widgets/cloud_session_card.dart`
**Role:** Card widget for a single cloud session entry in `CloudSessionsScreen`.

---

### `lib/features/cloud/widgets/cloud_session_placeholders.dart`
**Role:** Loading skeleton and error-state widgets shown while cloud sessions are being fetched.

---

## Features — Reports (`lib/features/reports/`)

### `lib/features/reports/notifiers/report_notifier.dart`
**Role:** Provider notifier for PDF report generation and sharing.

Exposes `generatePDFReport(...)` (builds the PDF in memory and returns the bytes) and `generateAndSharePDFReport(...)` (generates then calls `FileService.saveAndSharePdf`). It also can download the server-generated PDF via `ApiService.fetchServerPdf()`. Loads the lecturer's signature and name from `SignatureService` before calling `PdfService`.

---

## Features — Signature (`lib/features/signature/`)

### `lib/features/signature/screens/signature_setup_screen.dart`
**Role:** Screen where the lecturer draws and saves their digital signature.

Uses the `SignaturePad` widget. On save, the PNG bytes are persisted via `SignatureService`. Also lets the lecturer type their printed name. The saved signature and name are embedded in the generated PDF report.

---

### `lib/features/signature/widgets/signature_widgets.dart`
**Role:** Supporting widgets for the signature screen: save/clear buttons, the name text field, and the signature preview image.

---

## Models (`lib/models/`)

### `lib/models/attendance_record.dart`
**Role:** Data classes for a single student's attendance entry.

Contains `AttendanceRecord` (student identity, connection duration, `isVerified`, GPS location, device fingerprint, `isManual` flag) and `AttendanceLocation` (latitude, longitude, accuracy, address, timestamp). Both support `toJson()`/`fromJson()` and `copyWith()`.

---

### `lib/models/session.dart`
**Role:** Data class for a lecture session.

`AttendanceSession` holds course info, lecturer ID and name, session PIN and token, timing fields (start/end, duration, grace period, required connection minutes), and the `isActive` flag. Supports `toJson()`/`fromJson()` and `copyWith()`.

---

### `lib/models/student.dart`
**Role:** Data class for a registered student entity.

`Student` holds the student's matricule, name, optional email, and device fingerprint. Persisted per session in SharedPreferences via `StorageService`.

---

### `lib/models/catalogue_course.dart`
**Role:** Data class for a course entry in the local catalogue.

`CatalogueCourse` holds the UUID, `semesterId`, name, code, optional department and credits. Supports JSON serialization.

---

### `lib/models/semester.dart`
**Role:** Data class for a semester entry in the local catalogue.

`Semester` holds the ID, label, academic year, number (1/2/3), and `isActive` flag. Supports JSON serialization.

---

## Services (`lib/services/`)

### `lib/services/server_config.dart`
**Role:** Singleton that auto-detects which server URL to use and caches it for the entire app session.

On `detect()` (called at startup in `main.dart`), it runs a background isolate (`compute`) that follows a 7-step detection ladder:
1. HTTPS cloud (`https://owhas.org`) — fast 2-second probe.
2. Parallel LAN scan — fixed gateway IPs + 192.168.0.x / 192.168.1.x / 10.0.0.x subnets, all parallel, 800 ms timeout.
3. Hybrid resolution — if both local and cloud respond, marks `isHybrid = true`.
4. Slow-4G cloud retry (5 s).
5. Direct HTTP fallback (`http://owhas.org:5501`).
6. Final cloud retry.
7. Falls back to `http://192.168.137.1:5501` (Windows hotspot default).

Exposes `baseUrl`, `isOnline`, `isHybrid`, `getDynamicQrUrl()`, and `reset()` (used by the refresh button).

---

### `lib/services/api_service.dart`
**Role:** HTTP client for all communication with the Node.js backend.

All endpoints are prefixed with `ServerConfig().baseUrl`. Stores the active session PIN internally (set by `SessionStateNotifier`) and sends it as a query param or body field on every request. Key methods:
- `pingServer()` — health check.
- `registerStudentOnServer(...)` — POST `/connect`.
- `resetServerSession(...)` — POST `/api/reset`.
- `fetchServerAttendees()` — GET `/api/attendees?pin=`.
- `fetchServerStats()` — GET `/api/stats?pin=`.
- `pushSessionConfig(...)` — POST `/api/session-config`.
- `removeAttendeeOnServer(matricule)` — POST `/api/remove-attendee`.
- `verifySessionPin(pin)` — checks if a PIN is active.
- `parsePdfOnServer(pdfBytes)` — multipart upload to `/api/parse-pdf`.
- `fetchServerPdf()` — GET `/export?pin=` (server-generated PDF).

---

### `lib/services/cloud_service.dart`
**Role:** Firebase integration singleton — authentication, Firestore CRUD, and Storage.

Initializes Firebase and enables Firestore offline persistence. Auth: `signIn`, `signUp`, `signOut`, `sendPasswordReset`, `getLecturerProfile`. Session sync: `syncSession`, `updateSessionStats`, `syncAttendanceRecord`, `deleteSession`, `fullSessionSync` (batch write). Fetch: `fetchSessions`, `fetchRecords`, and real-time streams `streamSessions`, `streamRecords`. Storage: `uploadExport`, `listExports`, `downloadExport`. Firestore path structure: `lecturers/{uid}/sessions/{sessionId}/records/{recordId}`.

---

### `lib/services/session_service.dart`
**Role:** Session lifecycle orchestrator singleton.

`createSession(...)` generates a PIN and token, calls `_initServerSession` (POST `/api/session-init`) best-effort (network failures are non-fatal, only PIN conflicts (409) block), saves to local storage, syncs to Firebase if signed in, starts a 1-minute connection-tracking timer, and starts an auto-end timer at `durationMinutes`.

`registerStudent(...)` checks device fingerprint uniqueness, creates a `Student` record, collects GPS (in online mode), saves an `AttendanceRecord`, syncs to Firebase.

`registerManualStudent(...)` bypasses fingerprint checks (for dead-phone scenarios).

`endSession(...)` deactivates the session locally, calls `/api/end-session` on the server, then does a `fullSessionSync` to Firebase.

`resyncToServer()` re-pushes the active session to the server after a reconnection.

---

### `lib/services/storage_service.dart`
**Role:** Local persistence singleton using `SharedPreferences`.

Stores sessions under key `"sessions"` and attendance records under `"attendance_{sessionId}"` as JSON arrays. Also manages students (`"students_{sessionId}"`). All reads are lazy-initialized. Exposes: `saveSession`, `getSessions`, `getActiveSession`, `saveAttendanceRecord`, `getAttendanceRecords`, `deleteAttendanceRecord`, `saveStudent`, `getStudentByMatricule`, `deleteStudent`.

---

### `lib/services/face_recognition_service.dart`
**Role:** Session-scoped in-memory face recognition singleton.

Uses Google ML Kit's `FaceDetector` (accurate mode, contours enabled) to build a 456-value descriptor per face: 200 values from normalized contour points (face outline, eyes, nose, lips) + 256 values from an average-hash of the 16×16 face crop. Duplicate detection uses cosine similarity with threshold `0.82`. Key methods: `detectAndDescribe(imageFile)`, `findDuplicate(sessionId, descriptor)`, `storeFace(...)`, `clearSession(sessionId)`, `removeFace(sessionId, matricule)`.

---

### `lib/services/location_service.dart`
**Role:** GPS location singleton using the `geolocator` and `geocoding` packages.

Requests permission, gets high-accuracy position, reverse-geocodes it to a human-readable address, and returns a complete `AttendanceLocation`. `collectLocation()` is called during student registration (online mode) and session creation. Returns `null` gracefully if permission is denied or GPS unavailable.

---

### `lib/services/network_discovery_service.dart`
**Role:** LAN subnet scanner for counting active Wi-Fi devices.

Uses the `network_discovery` package to TCP-scan port 5501 on the configured subnet. Returns a `NetworkScanResult` with count and IP list. Called periodically from the lecturer dashboard to show how many devices are connected to the hotspot.

---

### `lib/services/course_service.dart`
**Role:** Catalogue CRUD service backed by SharedPreferences.

`seedFromManagement()` (called at startup) checks the stored seed version against `CourseManagement.version`; if different, wipes and rebuilds the local catalogue from the static data. Also provides `loadSemesters()`, `loadCourses()`, `saveCourse()`, `deleteCourse()`, `saveSemester()`, `deleteSemester()`, and legacy-key migration.

---

### `lib/services/device_service.dart`
**Role:** Device fingerprinting singleton.

Uses `device_info_plus` to build a unique string from Android device ID + model, iOS `identifierForVendor`, or web browser info. Cached after first call. Used by `SessionService` to detect if the same physical device tries to register twice for the same session.

---

### `lib/services/excel_service.dart`
**Role:** Previous-session file ingestion (Excel + PDF).

`uploadPreviousSession()` opens the system file picker (`.xlsx`, `.xls`, `.pdf`), reads the bytes, then parses Excel files locally (using the `excel` package) or uploads PDF bytes to the server (`/api/parse-pdf`) for server-side text extraction. Returns a `PreviousSessionResult` with a list of `StudentAttendanceData` (matricule, name, cumulative presence count) and the detected session number.

---

### `lib/services/pdf_service.dart`
**Role:** PDF report generator using the `pdf` package.

`PdfService.generateAttendancePDF(...)` builds an A4 multi-page PDF with: session header (course name, code, date, lecturer), a table of attendees (matricule, name, previous marks, current mark, cumulative total, status), summary stats, and an optional digital signature image + lecturer name at the bottom. `previousAttendance` is a `Map<matricule, int>` carrying marks from earlier sessions.

---

### `lib/services/file_service.dart`
**Role:** File save and native share service.

`saveAndSharePdf(bytes)` writes the PDF to the temp directory and opens the platform share sheet via `share_plus`. `savePdfToDevice(bytes)` writes directly to Android Downloads or iOS Documents.

---

### `lib/services/signature_service.dart`
**Role:** Lecturer digital signature persistence (static methods, no singleton).

Saves/loads the PNG signature bytes as base64 in SharedPreferences under `"lecturer_signature_png"`. Also saves/loads the lecturer's name under `"lecturer_name"`. Session-scoped signature deduplication (SHA-256 hash list) prevents the same drawn signature from being reused multiple times within one session.

---

## Shared Widgets (`lib/widgets/`)

### `lib/widgets/signature_pad.dart`
**Role:** Interactive drawing canvas for the lecturer's digital signature.

Touch/pointer events draw strokes on a `CustomPainter`. Exposes `getSignatureBytes()` to export the drawing as PNG bytes and `clear()` to reset.

---

### `lib/widgets/dashboard/session_header.dart`
**Role:** Top section of the dashboard showing course name, session PIN, start time, and elapsed duration.

---

### `lib/widgets/dashboard/qr_code_section.dart`
**Role:** Displays the session QR code (fetched dynamically from the server) that students scan to open the web registration page.

---

### `lib/widgets/dashboard/attendance_records_section.dart`
**Role:** Scrollable list of attendance records with per-student actions (manual verify, remove).

---

### `lib/widgets/dashboard/attendance_record_tile.dart`
**Role:** Single-row widget for one student's attendance record, showing name, matricule, connection time, and verification status badge.

---

### `lib/widgets/dashboard/attendance_records_section.dart`
*(see above — same file listed once)*

---

### `lib/widgets/dashboard/compact_stat_chip.dart`
**Role:** Small chip widget showing a label + count (e.g. "Verified: 12") used in the dashboard stats row.

---

## Pages (`lib/pages/`)

### `lib/pages/face_capture_page.dart`
**Role:** Full-screen camera page for the student face-capture step during registration.

Opens the front camera, shows an oval guide overlay, captures a photo on tap, runs `FaceRecognitionService.detectAndDescribe(imageFile)` to validate exactly one face and compute the descriptor, deletes the image immediately (never stored), and returns a `FaceCaptureResult` containing only the descriptor. Handles camera permission errors with user-friendly messages.

---

## Utils (`lib/utils/`)

### `lib/utils/dialog_helpers.dart`
**Role:** Reusable dialog utility functions.

Contains helpers like `showConfirmDialog(context, title, message)` that return a `bool` and are used by the dashboard to confirm destructive actions (end session, remove student).

---

## Architecture Summary

```
lib/
├── main.dart               ← Entry point, DI root
├── nav.dart                ← GoRouter config
├── theme.dart              ← Design tokens + Material 3 themes
├── firebase_options.dart   ← Auto-generated Firebase config
├── course_management.dart  ← Static institution catalogue (admin edits)
│
├── core/
│   ├── abstractions/       ← Abstract service contracts
│   ├── constants/          ← Route path constants
│   ├── extensions/         ← BuildContext + DateTime helpers
│   └── mixins/             ← LoadingMixin, SnackbarMixin
│
├── features/               ← Feature-first screen + notifier bundles
│   ├── home/               ← Landing screen + server status notifier
│   ├── session/            ← Session setup form + live dashboard
│   ├── attendance/         ← Student self-registration + record notifier
│   ├── catalogue/          ← Course catalogue CRUD screen
│   ├── cloud/              ← Firebase login + past-sessions viewer
│   ├── reports/            ← PDF generation notifier
│   └── signature/          ← Signature drawing + persistence screen
│
├── models/                 ← Plain Dart data classes (JSON serializable)
├── services/               ← Singletons: API, storage, Firebase, GPS, ML Kit
├── widgets/                ← Reusable widgets shared across features
├── pages/                  ← Legacy page entry points (FaceCapturePage)
└── utils/                  ← Stateless helpers (dialog_helpers)
```

**State management pattern:** Provider with `ChangeNotifier`. The three feature notifiers (`SessionStateNotifier`, `AttendanceRecordNotifier`, `ReportNotifier`) are thin orchestrators — they call service methods and expose state; all business logic and I/O live in the service singletons. `ServerStatusNotifier` is a fourth notifier used exclusively by the home screen indicator.
