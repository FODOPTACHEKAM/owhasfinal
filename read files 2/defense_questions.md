# OwHAS — FYP Defense Questions & Suggested Answers

Organised by topic. Each question includes a concise answer referencing your actual implementation.

---

## 1. SOFTWARE ARCHITECTURE

**Q1: Describe the overall architecture of your system.**
> OwHAS follows a three-tier architecture: (1) Flutter mobile app (lecturer dashboard + student registration), (2) Node.js REST API server (server.js), and (3) a browser-based captive portal (hotspot.html). The Flutter app uses Provider for state management with a feature-based folder structure. The server is stateless by design — sessions live in memory and are persisted to a JSON file for crash recovery. There is no traditional database.

**Q2: Why did you choose a feature-based folder structure over a layer-based one?**
> Feature-based organisation (home, session, attendance, catalogue, reports, signature) keeps related UI, notifiers, and widgets together. As the app grew to 6 features with 14 services and 4 notifiers, this prevented cross-feature coupling and made each feature independently navigable. A layer-based structure (all screens in one folder, all services in another) would have become unmanageable at this scale.

**Q3: What design patterns did you apply?**
> - **Observer pattern**: ChangeNotifier + Provider — notifiers hold state, widgets rebuild on changes
> - **Singleton pattern**: ServerConfig, all service classes — single instance shared across the app
> - **Two-phase commit**: Face verification issues a one-time token, registration consumes it atomically — prevents race conditions
> - **Strategy pattern**: Dual server detection (Workers VLAN first, then cloud, then local scan) with priority-based fallback
> - **Mixin pattern**: LoadingMixin extracts loading/error boilerplate shared by all 4 notifiers

**Q4: Why did you use Provider instead of BLoC, Riverpod, or GetX?**
> Provider is the officially recommended state management for Flutter. It is lightweight, has minimal boilerplate, and integrates naturally with ChangeNotifier. BLoC would add unnecessary complexity for this app's straightforward state flows. The 4 notifiers (Session, Attendance, Report, ServerStatus) each manage a single domain — Provider's simplicity fits this well.

**Q5: How does your app handle navigation?**
> GoRouter manages declarative routing with named routes defined in nav.dart. Routes include `/home`, `/setup`, `/dashboard`, `/register`, `/catalogue`, and `/signature`. GoRouter was chosen over Navigator 2.0 directly because it provides a cleaner API for deep linking and route guards.

**Q6: Explain the separation of concerns in your backend.**
> server.js is a single-file Express application with clearly separated sections: session management (create/end/config), face verification (two-phase commit), student registration (connect/biometric-connect), GPS heartbeat, attendance export (PDF), and captive portal (port 80 redirect). Each section handles its own validation, error responses, and logging. There is no ORM or database layer — the in-memory Map is the data store.

---

## 2. CI/CD & DEPLOYMENT

**Q7: Do you have a CI/CD pipeline? If not, how do you manage builds and deployments?**
> There is no automated CI/CD pipeline. Builds are done manually via `flutter build apk --release`. The APK is distributed directly to lecturer devices. The server is deployed manually via SSH to the cloud instance or copied to the VLAN machine. For a production system, I would add GitHub Actions for automated testing, linting, and APK generation on each push.

**Q8: How would you set up a CI/CD pipeline for this project?**
> I would use GitHub Actions with three stages: (1) **Lint & Test** — `flutter analyze` + `flutter test` on every PR, (2) **Build** — generate release APK and attach as artifact, (3) **Deploy** — SSH into the cloud server, pull latest server.js, restart the Node.js process via PM2 or systemd. The Flutter app would be distributed via Firebase App Distribution or a direct download link.

**Q9: Describe your deployment strategy.**
> Three deployment modes:
> - **Hotspot (offline)**: Lecturer runs `node server.js` on their laptop, enables Windows Mobile Hotspot. Students connect to the hotspot — captive portal opens automatically. No internet needed.
> - **VLAN (institutional)**: IT assigns a fixed IP (e.g. 10.13.14.164) on a dedicated VLAN (ICTU_ATD or Workers). Server runs as a service, starts on boot. DNS alias `atd.ictu.loc` for easy access.
> - **Cloud**: AWS EC2 with Nginx reverse proxy (port 443 → 5501), Let's Encrypt SSL, Cloudflare DNS at owhas.org.

**Q10: How does the app know which server to connect to?**
> ServerConfig runs a priority-based detection in a background isolate: (1) Check Workers VLAN IPs first (10.13.14.164, atd.ictu.loc), (2) Check cloud (owhas.org), (3) Parallel scan of 767+ local IPs (fixed gateways + three /24 subnets) with 800ms timeout, (4) Emulator loopback (10.0.2.2), (5) Fallback to default hotspot IP. The first server that responds to `/ping` wins.

**Q11: Why do you run server detection in a background isolate?**
> Scanning 767+ IP addresses with HTTP requests would block the UI thread for several seconds, causing jank. Dart's `compute()` function runs the detection in a separate isolate (thread), keeping the UI responsive. The result is cached in the ServerConfig singleton so detection only runs once per app launch.

---

## 2B. MVC / MVVM ARCHITECTURE

**Q: Does your project follow MVC? Explain.**
> Not traditional MVC. Flutter with Provider naturally follows **MVVM** (Model-View-ViewModel). The mapping in OwHAS is:
> - **Model**: Pure data classes — `AttendanceSession`, `AttendanceRecord`, `CatalogueCourse`, `Semester`, `Student`. Each has `toJson()`, `fromJson()`, `copyWith()`, and no business logic.
> - **View**: Screens and widgets — `home_screen.dart`, `lecturer_dashboard_screen.dart`, `student_registration_screen.dart`, plus extracted widgets like `SemesterTile`, `RoleCard`, `SessionHeader`.
> - **ViewModel**: ChangeNotifier classes — `SessionStateNotifier`, `AttendanceRecordNotifier`, `ReportNotifier`, `ServerStatusNotifier`. They hold state, expose it to Views via Provider, and call Services for data operations.
> - **Service layer** (below ViewModel): `ApiService`, `StorageService`, `SessionService`, `FaceRecognitionService` — handle data access, network, and persistence.
>
> The key difference from MVC: in MVC the Controller receives user input and updates the Model directly. In MVVM the ViewModel exposes observable state that Views bind to — Flutter's `Consumer<T>` widget rebuilds automatically when the notifier calls `notifyListeners()`. There is no Controller.

**Q: Why MVVM over MVC for a Flutter app?**
> MVC was designed for web frameworks (Rails, Django, ASP.NET) where the Controller handles HTTP requests. Flutter is reactive — the UI rebuilds when state changes. MVVM fits this naturally: the ViewModel (Notifier) holds state, the View (Widget) observes it via Provider, and the Model is a plain data object. Attempting MVC in Flutter would fight the framework's reactive design.

**Q: How does data flow through your MVVM layers?**
> Example — student registration:
> 1. **View** (`student_registration_screen.dart`): User taps "Register" → calls `rn.registerStudent()`
> 2. **ViewModel** (`AttendanceRecordNotifier`): Calls `_sessionService.registerStudent()` (local storage) + `_apiService.registerStudentOnServer()` (server), then `refreshRecords()` to merge local + server data, then `notifyListeners()`
> 3. **Service** (`SessionService`): Creates an `AttendanceRecord` model, persists to SharedPreferences
> 4. **Service** (`ApiService`): POSTs to `/connect` on the Node.js server
> 5. **Model** (`AttendanceRecord`): Pure data object — serialised to JSON for storage, deserialised on read
> 6. **View**: `Consumer<AttendanceRecordNotifier>` detects the change and rebuilds the dashboard list

**Q: Where does the Node.js backend fit in MVC/MVVM?**
> The Node.js server follows a simpler **Service-Oriented Architecture**. It has no views (it serves a static HTML file). The closest MVC mapping would be: Routes = Controller (handle HTTP requests, validate input), In-memory Map = Model (session data), and hotspot.html = View (rendered in the student's browser, not on the server). But calling it MVC would be a stretch — it is a stateless REST API with in-memory storage.

**Q: How do your Models enforce data integrity?**
> Models are immutable (`final` fields) with `copyWith()` for safe updates. Validation happens at the ViewModel and Service layers, not in the Model. For example, `AttendanceRecord` does not validate that `matricule` is 4-20 characters — that check lives in the server endpoint and the Flutter form validator. Models are data containers, not business logic holders.

**Q: Compare your architecture to a traditional MVC web app.**
> | Concern | Traditional MVC (e.g. Django) | OwHAS (MVVM + Services) |
> |---------|------|------|
> | User input | Controller (HTTP handler) | View (Widget onTap) → ViewModel (Notifier method) |
> | Business logic | Controller + Model | ViewModel (Notifier) + Service layer |
> | Data access | Model (ORM queries) | Service (SharedPreferences, HTTP, Firebase) |
> | State propagation | Controller → Template rendering | Notifier.notifyListeners() → Widget rebuild |
> | Data objects | Model (Active Record) | Model (plain Dart class, no DB coupling) |

---

## 3. SECURITY

**Q12: How do you prevent proxy attendance (a student signing for an absent friend)?**
> A 7-layer verification chain: (1) Session PIN restricts access, (2) GPS geofence ensures physical presence, (3) IP-based device fingerprinting limits one registration per device, (4) Face uniqueness check via Euclidean distance (threshold 0.45) blocks duplicate faces, (5) One-time face token with 5-minute TTL prevents replay, (6) Matricule duplicate check, (7) GPS heartbeat every 2 minutes verifies sustained presence.

**Q13: Explain your face recognition approach.**
> Two systems run in parallel. The browser uses face-api.js (TinyFaceDetector + FaceRecognitionNet) producing a 128-dimensional descriptor. The Flutter app uses Google ML Kit producing a 456-dimensional descriptor (200 geometric contour points + 256 binarised pixel texture). The server compares descriptors using Euclidean distance with a 0.45 threshold — below this means same person, registration blocked.

**Q14: What is the two-phase commit for face registration?**
> Phase 1: POST `/api/verify-face` checks the face descriptor against all registered faces. If unique, it issues a one-time `faceId` token (UUID, valid 5 minutes). Phase 2: POST `/api/biometric-connect` consumes the token atomically — it re-checks uniqueness at commit time to catch race conditions where two phones submit the same face simultaneously. The first one wins, the second is rejected.

**Q15: How do you handle liveness detection (photo spoofing)?**
> An expression-based challenge using the already-loaded faceExpressionNet model. In webcam mode: the system detects a neutral face first (happy < 0.3 for 2 consecutive frames), then prompts "Now smile!" and waits for happy > 0.55. A printed photo cannot change expression, so it times out. In mobile mode: two sequential photos required — neutral then smiling — with descriptor cross-check to verify same person. After 3 failed attempts or 10-second timeout, fallback captures with `livenessVerified: false` to avoid blocking legitimate users.

**Q16: How do you handle GPS spoofing?**
> GPS spoofing is acknowledged as a limitation — it requires the student to knowingly install a third-party app. The system mitigates this with: (1) GPS accuracy checking — if accuracy exceeds 300m, the geofence is waived entirely (indicating indoor/unreliable GPS, not spoofing), (2) Heartbeat continuity — spoofed coordinates that suddenly jump are detectable by the 2-minute heartbeat interval, (3) The primary anti-proxy defence is face recognition, not GPS alone.

**Q17: How do you protect the session PIN from brute-force attacks?**
> Rate limiting: 10 attempts per IP address per 5 minutes on the `/api/validate-pin` endpoint. After 10 failed attempts, the server returns HTTP 429. The PIN space is 1000-9999 (9000 possible values), so even without rate limiting, brute-force requires significant time.

**Q18: Why don't you use HTTPS on the local hotspot?**
> The hotspot is a private LAN with no internet access — there is no certificate authority to issue a valid TLS certificate. Self-signed certificates would trigger browser warnings on every student's phone. Since the network is physically isolated (only devices connected to the lecturer's hotspot can access the server), the attack surface is minimal. For the cloud deployment, Nginx provides HTTPS via Let's Encrypt.

**Q19: How do you handle face data privacy (GDPR compliance)?**
> Face descriptors are stored in-memory only — never written to disk or a database. When the session ends or the server restarts, all face data is permanently lost. GPS coordinates are discarded immediately after the Haversine distance check. The `sessions.json` crash-recovery file stores session metadata but never face descriptors.

---

## 4. DATABASE & STORAGE

**Q20: Why did you choose in-memory storage instead of a database?**
> The system is designed to work offline on a laptop hotspot. Installing and configuring a database (MySQL, MongoDB, PostgreSQL) would add deployment complexity and a dependency the lecturer may not have. An in-memory Map with JSON file backup provides sufficient persistence for sessions that last 1-3 hours. The data is transient by nature — once the attendance PDF is generated, the raw data is no longer needed.

**Q21: What happens if the server crashes mid-session?**
> Every state change (registration, heartbeat, session config) triggers a write to `sessions.json`. On restart, the server reads this file and restores all active sessions with their attendees. The lecturer's Flutter app auto-reconnects on the next poll cycle (5 seconds). Students who registered before the crash remain registered. The only data lost is pending face tokens (by design — they have a 5-minute TTL anyway).

**Q22: How do you handle data on the Flutter side?**
> SharedPreferences stores session metadata, attendance records, course catalogue, lecturer name, and digital signature. Data is keyed by session ID to prevent cross-session conflicts. Firebase Firestore provides optional cloud sync for cross-device session history, but the app works fully offline without it.

**Q23: Why SharedPreferences instead of SQLite or Hive?**
> The data model is simple — flat lists of sessions, records, and courses. SharedPreferences with JSON serialisation is sufficient and requires no additional dependencies or schema management. SQLite would be overkill for storing a few hundred attendance records per session. If the app needed complex queries or relational data, I would switch to Drift (SQLite wrapper for Flutter).

---

## 5. TESTING

**Q24: What is your testing strategy?**
> The project uses manual testing on real devices as the primary verification method. Unit tests exist for basic widget verification. The most critical test was 30 simultaneous registrations from 30 phones on the same hotspot — no race conditions or duplicate faces passed. Integration testing covered captive portal triggering on Android 12, iOS 16, and Windows 11. Face de-duplication was tested with 50 registrations across multiple sessions.

**Q25: Why didn't you write more automated tests?**
> Time constraints of the FYP timeline. The face recognition, GPS heartbeat, and captive portal features require real device testing — they cannot be meaningfully unit-tested with mocks. For a production release, I would add: (1) unit tests for PIN generation, Haversine distance, face distance calculation, (2) widget tests for the registration flow, (3) integration tests using `flutter_test` with a mock server.

**Q26: How would you test the face recognition system?**
> (1) **True positive rate**: Register 50 unique faces, verify all pass. (2) **True negative rate**: Attempt to register the same face twice — verify rejection. (3) **Threshold tuning**: Vary the Euclidean distance threshold (0.35–0.55) and measure false acceptance/rejection rates. (4) **Lighting conditions**: Test in bright, dim, and backlit environments. (5) **Liveness**: Hold up printed photos and phone screens — verify the expression challenge blocks them.

---

## 6. PERFORMANCE & SCALABILITY

**Q27: How does the system perform under load?**
> Tested with 30 simultaneous registrations on a single hotspot. The Node.js event loop handles concurrent requests efficiently since face comparison (Euclidean distance on 128 floats) is computationally trivial (~0.1ms per comparison). The bottleneck is network bandwidth on the hotspot, not server CPU. Server IP detection takes a median of 340ms (767 IPs scanned in parallel with 800ms timeout).

**Q28: What are the scalability limitations?**
> (1) In-memory session storage limits to available RAM — at ~2KB per attendee, 200 students per session uses ~400KB, well within limits. (2) Single-server architecture — no horizontal scaling. (3) Hotspot mode supports ~10-15 concurrent Wi-Fi connections (Windows limitation). (4) Face comparison is O(n) against all registered faces — at 200 students, this is still under 1ms. For 1000+ students, an indexing structure (e.g. VP-tree) would be needed.

**Q29: How do you handle slow or unreliable networks?**
> (1) Server detection has layered timeouts: 800ms for local, 2s for cloud, 5s for slow 4G. (2) The captive portal works on the local hotspot with zero internet dependency. (3) The Flutter app polls every 5 seconds with 10-second HTTP timeouts. (4) GPS heartbeats tolerate 1 missed beat (grace period) before flagging. (5) The two-phase face commit has a 5-minute token TTL to accommodate slow connections.

**Q30: Why did you use a background isolate for server detection?**
> Dart is single-threaded. Scanning 767+ IP addresses with HTTP requests on the main thread would freeze the UI for 1-3 seconds. The `compute()` function offloads the work to a separate isolate, keeping the app responsive during detection. The detection result is cached in a singleton, so it runs only once per session.

---

## 7. API DESIGN

**Q31: Why REST instead of WebSockets or GraphQL?**
> REST is simpler to implement and debug. The attendance flow is request-response by nature — register, verify, submit. There is no need for real-time bidirectional communication (WebSockets) or complex query flexibility (GraphQL). The dashboard polls every 5 seconds via GET `/api/stats`, which is efficient enough for a classroom setting. WebSockets would add complexity for marginal latency improvement.

**Q32: How do you handle API versioning?**
> There is no API versioning. The server and client are deployed together — the lecturer controls both. If the API changes, a new APK is distributed alongside the updated server.js. For a multi-tenant production system, I would add `/api/v1/` prefixes and maintain backward compatibility.

**Q33: How do you validate API inputs?**
> Server-side validation at each endpoint: (1) Required field checks — missing username/matricule/email returns 400. (2) Length limits — username ≤ 100, matricule ≤ 30, email ≤ 150. (3) PIN format — must be exactly 4 digits. (4) Face descriptor — must be a 128-element numeric array. (5) JSON body size limited to 10KB, PDF uploads to 5MB. (6) Rate limiting on sensitive endpoints (PIN validation, registration).

**Q34: What HTTP status codes do you use and why?**
> - 200: Success (registration confirmed, data returned)
> - 400: Bad request (missing fields, invalid format)
> - 403: Forbidden (geofence violation, face already registered, expired token)
> - 404: Not found (session/PIN not found)
> - 409: Conflict (duplicate matricule)
> - 429: Too many requests (rate limit exceeded)
> Each code triggers a specific user-friendly error message on the client side.

---

## 8. CAPTIVE PORTAL & NETWORKING

**Q35: How does the captive portal work?**
> When a phone connects to the hotspot, the OS sends a probe request (e.g. Android: GET /generate_204, iOS: GET /hotspot-detect.html). The server on port 80 intercepts these probes and returns a 302 redirect to hotspot.html on port 5501. The phone detects "captive portal" and shows a "Sign in to network" notification. The student taps it — the attendance page opens automatically. No URL to type, no QR code needed.

**Q36: How many OS-specific captive portal probes do you handle?**
> Nine probe paths: Android (/generate_204, /gen_204, /connectivitycheck), iOS (/hotspot-detect.html), Windows (connecttest.txt, ncsi.txt), Firefox (/success.txt), Ubuntu (/connectivity-check), and macOS (/library/test/success.html). Each returns the appropriate response to trigger the captive portal UI on that OS.

**Q37: What happens if the captive portal doesn't trigger?**
> Three fallback mechanisms: (1) mDNS broadcasts `owhas.local` — students can type this in their browser. (2) LAN DNS serves `owhas.lan` as an alias. (3) The lecturer can share the QR code from the dashboard — scanning it opens the registration page directly.

---

## 9. MOBILE-SPECIFIC CONCERNS

**Q38: How do you handle camera permissions?**
> The Flutter app requests camera permission before opening the face capture page. If denied, an error message explains why the camera is needed. On the web portal, `<input capture="user">` opens the native camera on mobile without needing HTTPS. On desktop, `getUserMedia()` requires a secure context (HTTPS or localhost) — the ngrok tunnel provides this for hybrid mode.

**Q39: How do you handle GPS accuracy issues?**
> The geofence radius (50m) is extended by the GPS accuracy reading. If a phone reports ±30m accuracy, the effective radius becomes 80m. If accuracy exceeds 300m (indoor, weak signal), the geofence check is waived entirely — the student is admitted without location verification. The Refresh GPS button lets students manually retry with a 20-second timeout for a better fix.

**Q40: How does the app work on both Android and iOS?**
> Flutter compiles to native code for both platforms from a single Dart codebase. Platform-specific considerations: (1) Camera API uses the `camera` package which abstracts Android/iOS differences. (2) GPS uses the `geolocator` package for cross-platform location. (3) The web portal (hotspot.html) works in Chrome (Android), Safari (iOS), and Edge (Windows) — pure HTML/JS with no platform dependencies.

---

## 10. REPORT GENERATION

**Q41: How do you generate attendance reports?**
> The Flutter app generates PDF reports entirely on-device using the `pdf` package — no server call needed. The PDF includes: session metadata (course, date, duration), attendance table (matricule, name, join time, duration, verified status), summary statistics (total/verified/pending), and an embedded digital signature. Excel reports support cumulative tracking across multiple sessions.

**Q42: How does cumulative attendance tracking work?**
> The lecturer uploads a previous session's Excel/PDF file before starting a new session. The ExcelService parses it to extract matricule-to-total mappings and the last session number. After the current session, the PDF shows a Master Roster with previous totals, new totals, and percentage change. Session numbers auto-increment (Session 3 → Session 4).

---

## 11. GENERAL SOFTWARE ENGINEERING

**Q43: What were the biggest technical challenges?**
> (1) **Captive portal on all OS families** — 9 different probe paths to intercept. (2) **Race condition on face registration** — two phones submitting the same face simultaneously. Solved with two-phase commit and re-check at commit time. (3) **Server IP detection** — changes on every hotspot session. Solved with parallel 767-IP scan in a background isolate. (4) **Camera on HTTP** — browsers block getUserMedia on plain HTTP. Solved with native camera input on mobile and ngrok HTTPS tunnel for desktop.

**Q44: If you could start over, what would you do differently?**
> (1) Use SQLite (via Drift) instead of SharedPreferences for better query support. (2) Add WebSocket support for instant dashboard updates instead of 5-second polling. (3) Write automated tests from the beginning. (4) Use a monorepo tool (Melos) to manage the Flutter app and Node.js server together. (5) Consider Flutter Web for the student portal instead of plain HTML/JS to share code with the mobile app.

**Q45: How do you handle error states in the UI?**
> LoadingMixin provides a standardised pattern: `runWithLoading()` wraps async operations, automatically setting `isLoading` and capturing exceptions into an `error` string. Widgets check `isLoading` to show spinners and `error` to show error messages. SnackBar helpers (`showSuccess`, `showError`, `showInfo`) provide consistent feedback. Network errors include actionable suggestions ("Check you are on the hotspot").

**Q46: How do you ensure code quality without CI/CD?**
> (1) `flutter analyze` for static analysis before each commit. (2) Feature-based folder structure enforces separation of concerns. (3) Abstract base classes for services (BaseApiService, BaseSessionService) define contracts. (4) Consistent patterns — all notifiers use LoadingMixin, all models have toJson/fromJson/copyWith. (5) Code review against the project document specifications.

**Q47: What is your approach to offline-first design?**
> Local-first: SharedPreferences stores sessions and records locally. Server registration is a best-effort operation — if it fails, the local record still exists. The server itself works offline (hotspot mode, no internet). Cloud sync via Firebase is optional and additive. The app never blocks on a network call — timeouts are strict and fallbacks are immediate.

**Q48: How do you handle concurrent access to shared state?**
> Dart's single-threaded event loop eliminates most concurrency issues. On the server side (Node.js, also single-threaded), the two-phase face commit handles the only critical race condition: `verify-face` reserves a token, `biometric-connect` atomically consumes it with a re-check. The `pending.used = true` flag is set synchronously before any await, making it safe against concurrent requests.

**Q49: What third-party dependencies are critical and what are their risks?**
> Critical: `face-api.js` (browser face recognition — no longer actively maintained, but stable), `google_mlkit_face_detection` (Flutter face detection — maintained by Google), `geolocator` (GPS — actively maintained). Risks: face-api.js could become incompatible with future browsers. Mitigation: the 5 model weights are served locally, not from a CDN, so they work offline and are version-locked.

**Q50: How would you scale this system for an entire university?**
> (1) Replace in-memory storage with PostgreSQL or MongoDB. (2) Add a load balancer (Nginx upstream) with multiple Node.js workers. (3) Use Redis for session state sharing across workers. (4) Replace polling with WebSockets for real-time updates. (5) Add user authentication (lecturer accounts with JWT). (6) Deploy the server as a Docker container for reproducible deployments. (7) Add monitoring (Prometheus + Grafana) and structured logging (Winston).
