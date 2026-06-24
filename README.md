# OwHAS — Hotspot Attendance System

A mobile app and server that lets lecturers take attendance using face recognition and GPS.
Built with Flutter (the phone app) and Node.js (the server that runs on a Windows PC).

---

## What the system does

1. The lecturer opens the app, picks a course, and starts a session. The app shows a 4-digit PIN.
2. Students connect to the lecturer's Wi-Fi hotspot, open a browser on their phone, enter the PIN, fill in their name and ID, then take a selfie.
3. The lecturer's screen updates every 5 seconds showing who has registered and how long they have been present.
4. When time is up, the session closes automatically. An Excel attendance sheet is saved and a notification appears on the lecturer's phone.

---

## Folder map — what lives where

```
owhasfinal/
|
+-- lib/                        The phone app (Flutter / Dart)
|   |
|   +-- config.dart             START HERE — change any setting from this one file
|   +-- main.dart               App startup code
|   +-- nav.dart                Screens and navigation routes
|   +-- theme.dart              Colours and fonts
|   +-- course_management.dart  The list of courses shown in the app
|   +-- firebase_options.dart   Firebase connection details (auto-generated)
|   |
|   +-- features/               Each folder is one section of the app
|   |   +-- home/               Home screen — choose Lecturer or Student role
|   |   +-- session/            Create a session and view the live dashboard
|   |   +-- attendance/         Student registration screen
|   |   +-- catalogue/          Browse and manage the course list
|   |   +-- reports/            Generate and share Excel or PDF reports
|   |   +-- cloud/              Log in and browse cloud-saved sessions
|   |   +-- signature/          Lecturer signature setup
|   |
|   +-- services/               Code that talks to outside systems
|   |   +-- api_service.dart             Sends requests to the Node.js server
|   |   +-- face_recognition_service.dart  Detects and compares faces on the phone
|   |   +-- session_service.dart          Saves session data on the phone
|   |   +-- storage_service.dart          Reads and writes to phone storage
|   |   +-- notification_service.dart     Sends push notifications to the lecturer
|   |   +-- server_config.dart            Finds the server automatically at startup
|   |   +-- cloud_service.dart            Syncs data with Firebase
|   |   +-- excel_service.dart            Builds the attendance Excel file
|   |   +-- location_service.dart         Gets the phone's GPS position
|   |   +-- (and 6 more smaller services)
|   |
|   +-- models/                 Simple data objects (no logic)
|   |   +-- session.dart
|   |   +-- attendance_record.dart
|   |   +-- student.dart
|   |   +-- catalogue_course.dart
|   |   +-- semester.dart
|   |
|   +-- widgets/                Small reusable screen pieces
|   |   +-- dashboard/          Tiles and cards shown on the lecturer dashboard
|   |   +-- signature_pad.dart
|   |
|   +-- pages/
|   |   +-- face_capture_page.dart   Camera screen for taking the selfie
|   |
|   +-- core/                   Internal helpers (routing names, mixins, extensions)
|
+-- backend/                    The server (Node.js)
|   +-- server.js               Main server file — CONFIG block is at the very top
|   +-- setup.js                Downloads the face recognition models (run once)
|   +-- start-server.bat        Windows launcher — just double-click this
|   +-- package.json            Server dependencies
|   +-- sessions.json           Saves session data so it survives a server restart
|   +-- src/services/
|   |   +-- pdfService.js       Builds the attendance PDF
|   +-- public/
|       +-- hotspot.html        The web page students open on their phones
|       +-- lib/face-api.min.js Face recognition library used in the browser
|       +-- models/             AI model files for face recognition (~6 MB total)
|
+-- android/
|   +-- app/
|       +-- build.gradle.kts        Android build settings and package name
|       +-- src/main/
|           +-- AndroidManifest.xml App permissions and app label (name shown on phone)
|           +-- res/                App icon files
|
+-- assets/icons/               Icons used inside the app
+-- OHAS2.png                   The source image for the app icon
+-- pubspec.yaml                App version and package list
```

---

## Where to change things

### The two most important files

| File | What you change here |
|---|---|
| `lib/config.dart` | Server address, face sensitivity, dashboard speed, session time defaults |
| `backend/server.js` — top CONFIG block | Port number, hotspot vs school Wi-Fi mode, GPS fence size, face sensitivity |

### Full list

| What to change | File | Field name |
|---|---|---|
| App name shown on phone screen | `android/app/src/main/AndroidManifest.xml` | `android:label` |
| App icon | Replace `OHAS2.png`, then run `flutter pub run flutter_launcher_icons` | — |
| App colours | `lib/theme.dart` | `LightModeColors` and `DarkModeColors` |
| App font | `lib/theme.dart` | `fontFamily` inside `_buildTextTheme` |
| Android package name | `android/app/build.gradle.kts` | `applicationId` |
| Course list | `lib/course_management.dart` | `CourseManagement.courses` |
| Firebase project | `lib/firebase_options.dart` and `android/app/google-services.json` | Replace both files |
| Server port | `backend/server.js` → `PORT` and `lib/config.dart` → `serverPort` | Change both to the same number |
| Hotspot vs school Wi-Fi mode | `backend/server.js` → `SERVER_IP` | `null` = hotspot, `'10.x.x.x'` = school Wi-Fi |
| Cloud server web address | `lib/config.dart` → `cloudUrl` and `cloudUrlHttp` | Your domain name |
| GPS classroom boundary size | `backend/server.js` → `GEOFENCE_RADIUS_M` | Metres, default is 50 |
| Face match strictness (app) | `lib/config.dart` → `faceMatchThreshold` | 0.0 to 1.0, higher means stricter |
| Face match strictness (server) | `backend/server.js` → `FACE_DISTANCE_THRESHOLD` | Lower means stricter |
| How often GPS is checked | `backend/server.js` → `HEARTBEAT_INTERVAL_MINUTES` | Minutes, default is 2 |
| How many missed GPS pings are allowed | `backend/server.js` → `HEARTBEAT_GRACE_PERIODS` | Default is 1 |
| Minimum time to count as present | `backend/server.js` → `DEFAULT_REQUIRED_MINUTES` | Minutes, default is 15 |
| How fast the dashboard refreshes | `lib/config.dart` → `dashboardRefreshSeconds` | Seconds, default is 5 |

---

## How to run it for the first time

### What you need installed
- Flutter 3.6 or newer
- Node.js 18 or newer
- A Windows PC (to run the server and create the hotspot)

### Step 1 — Start the server

Open a terminal inside the `backend` folder and run:

```
npm install
node setup.js
node server.js
```

`node setup.js` downloads the face recognition files from the internet. You only need to do this once.
After that, just run `node server.js` each time, or double-click `start-server.bat`.

The terminal will print the address students need to open in their browser.

### Step 2 — Run the phone app

```
flutter pub get
flutter run
```

The app will find the server on its own. If it cannot connect, make sure the phone and the PC are on the same Wi-Fi.

### Step 3 — Firebase (only needed for cloud features)

Replace `lib/firebase_options.dart` and `android/app/google-services.json` with your own Firebase project files. You can generate them by running:

```
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## Two ways to use the system

### Option 1 — Personal hotspot (easiest, works anywhere)

The lecturer's PC creates its own Wi-Fi hotspot. Students connect to that hotspot.
No IT department or school network needed.

To use this mode, make sure `backend/server.js` has:
```
const SERVER_IP = null;
```

### Option 2 — School Wi-Fi

The server runs on the school's fixed network. Students use the normal school Wi-Fi.
The IT department needs to give you a fixed IP address (for example `10.50.1.5`).

Set that IP in `backend/server.js`:
```
const SERVER_IP = '10.50.1.5';
```

See `WLAN.md` for the full guide on setting this up.

---

## How the system checks that students are really present

1. **4-digit PIN** — students must know the PIN the lecturer shows them
2. **GPS check at entry** *(school Wi-Fi sessions)* — the phone must be within 50 metres of the classroom
3. **One device, one student** — the same phone cannot register two different people
4. **Face scan** — the system checks that no one else already registered with the same face (blocks proxy attendance)
5. **GPS check every 2 minutes** *(school Wi-Fi sessions)* — if the student leaves the classroom, their time stops counting
6. **Minimum time** — the student must stay long enough to be marked as verified (green)

See `presence_recognition.md` for a full explanation of each step.

---

## Other documentation files

| File | What it explains |
|---|---|
| `lib/config.dart` | Every setting the app uses, with explanations |
| `WLAN.md` | How to deploy on the school Wi-Fi instead of a personal hotspot |
| `presence_recognition.md` | How the system checks that students are genuinely present |
| `storage_duration.md` | How the time counter works and why a student's row sometimes disappears |
| `after_registration.md` | What happens after a student registers, including registering for more than one course |




By FODOP TACHEKAM IVAN JORDAN 