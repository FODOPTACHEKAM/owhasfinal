# OwHAS — FYP PowerPoint Presentation Outline
# Offline Wi-Fi Hotspot Attendance System

Use this file to build your presentation slide by slide.
Each section gives you: slide title, bullet content, a visual to add, speaker notes, and a suggested duration.

Total slides: 10 · Estimated time: 10 minutes

---

## SLIDE 1 — Title Slide

**Title:** OwHAS — Offline Wi-Fi Hotspot Attendance System

**Subtitle:** A Biometric, Captive-Portal-Based Attendance System
with GPS Presence Enforcement

**Your name · Institution · Supervisor · Date**

**Visual:** App icon / logo centered on a dark gradient background.
University seal bottom-left.

**Speaker notes:**
Good [morning/afternoon]. My name is [name]. Today I present OwHAS —
Offline Wi-Fi Hotspot Attendance System — a system I designed to eliminate
proxy attendance in university classrooms without requiring an internet connection.

**Duration:** 30 s

---

## SLIDE 2 — Problem & Objectives

**Title:** The Problem and Our Objectives

**Left column — The Problem:**
- Paper lists are slow and proxy-prone (a student signs for an absent friend)
- Internet-dependent apps (QR, NFC) fail when Wi-Fi is weak or absent
- No existing system verifies a student stayed for the full session
- Dedicated hardware (RFID readers, fingerprint scanners) is expensive

**Right column — Objectives:**
1. Build an attendance system that works entirely over a local Wi-Fi hotspot
2. Prevent proxy attendance using real-time face recognition
3. Enforce sustained presence with GPS heartbeat monitoring
4. Produce verifiable PDF/Excel attendance reports

**Visual:** Split layout — problem icons on the left, numbered objectives on the right.

**Speaker notes:**
Every lecturer knows the problem. Paper attendance is easy to fake. QR-code apps
need internet. I wanted a solution that works with nothing but the lecturer's laptop.
These four objectives drove every design decision.

**Duration:** 1 min 30 s

---

## SLIDE 3 — System Architecture

**Title:** OwHAS — How It Works

**Visual (full-slide diagram):**

```
┌─────────────────────────────────────────────────┐
│          LECTURER'S PC / VLAN SERVER             │
│   Node.js server.js                              │
│   Port 5501 — REST API + hotspot.html            │
│   Port 80   — Captive portal redirect            │
│   Port 53   — LAN DNS (owhas.lan)                │
└─────────────────────────────────────────────────┘
       ↑ Wi-Fi hotspot / ICTU_ATD VLAN
┌──────────────────────┐    ┌──────────────────────┐
│  Student Phone       │    │  Lecturer Phone       │
│  Browser-based       │    │  Flutter App          │
│  Face capture + GPS  │    │  Dashboard + Reports  │
└──────────────────────┘    └──────────────────────┘
```

**Bullets:**
- Server runs on the lecturer's PC or a university VLAN server
- Students connect to Wi-Fi — captive portal opens attendance page automatically
- Lecturer controls everything through the Flutter mobile app
- No app install needed on the student side — pure browser

**Speaker notes:**
Three components. The Node.js server, the student's browser, and the lecturer's
Flutter app. When a student connects to the Wi-Fi, the captive portal intercepts
the connection and opens the attendance page automatically — like hotel or airport Wi-Fi.
No URL to type, no QR code needed.

**Duration:** 1 min 30 s

---

## SLIDE 4 — Student Registration Flow

**Title:** Student Experience — 30 Seconds to Register

**Visual:** Three-step phone mockup flow:

```
[1. Enter PIN]  →  [2. Face Capture]  →  [3. Name + Matricule]
                        │
                   face-api.js
                   (runs in browser)
                        │
                   Server verifies
                   face uniqueness
```

**Bullets:**
- Student connects to Wi-Fi → captive portal notification appears → tap to open
- Step 1: Enter 4-digit PIN from the lecturer
- Step 2: Take a selfie — face-api.js runs client-side in the browser (no server GPU)
- Step 3: Fill in name, student ID, and email → registered
- Works on Android, iOS, Windows — Chrome, Safari, Edge

**Speaker notes:**
The entire process takes under 30 seconds. The student connects to Wi-Fi,
taps the notification, enters the PIN, takes a selfie, fills in their details.
Done. No app to install. No account to create. The face recognition model
runs entirely in the student's browser.

**Duration:** 1 min

---

## SLIDE 5 — Face Recognition Anti-Proxy

**Title:** Biometric De-Duplication — Blocking Proxy Attendance

**Visual:** Diagram showing face descriptor comparison:
```
Student A registers → 128-D face descriptor stored in memory
Student B tries to register with Student A's face
  → Euclidean distance < 0.45 → BLOCKED
  → "Face already registered under Student A"
```

**Bullets:**
- face-api.js: TinyFaceDetector + FaceRecognitionNet — runs in the browser
- 128-number face descriptor compared against all registered faces
- Euclidean distance threshold: 0.45 — duplicate face = registration blocked
- Two-phase commit with one-time `faceId` token (5-min TTL) prevents race conditions
- Face data is in-memory only, never written to disk (privacy by design)

**Speaker notes:**
This is the core anti-proxy mechanism. A student cannot sign for a friend because
every face must be unique. The two-phase commit handles the edge case where two
phones submit the same face simultaneously — the first one wins, the second is rejected.
Face descriptors are never saved to storage — they exist only in server memory and
are discarded when the session ends.

**Duration:** 1 min 30 s

---

## SLIDE 6 — GPS Presence Enforcement

**Title:** GPS Heartbeat — Proving Sustained Presence

**Visual:**
```
Session created with GPS boundary (classroom +/- 50 m)
       ↓
Student registers → receives heartbeatToken
       ↓
Browser sends GPS heartbeat every 2 minutes
       ↓
Server checks Haversine distance:
  Within 50 m → lastSeen updated (present)
  Beyond 50 m → leftEarly = true (flagged)
```

**Bullets:**
- Registration alone is not enough — the system tracks continued presence
- Heartbeat every 2 minutes with per-student UUID token (prevents replay attacks)
- 1 missed heartbeat tolerated (grace period), then student flagged as left early
- `leftEarly` flag freezes the student's attendance duration permanently
- GPS coordinates discarded after validation (privacy by design)

**Speaker notes:**
A student who registers and then walks out is caught. Their heartbeats stop,
the server flags them as left early, and their attendance duration freezes.
The lecturer sees this in real-time on the dashboard.

**Duration:** 1 min

---

## SLIDE 7 — Lecturer Flutter App

**Title:** Flutter App — Session Management & Live Dashboard

**Visual:** Two phone mockups side by side:
- Left: Session Setup screen (course name, PIN, duration fields)
- Right: Live Dashboard (student list with verified/pending status, stats, QR code)

**Bullets:**
- Built with Flutter (Provider + GoRouter) — Android + iOS from one codebase
- Session setup: course name, duration, grace period, required connection time
- Live dashboard: auto-refreshes every 5 seconds with verified/pending/total counts
- Server auto-detection: background isolate scans 767 LAN IPs in parallel (median 340 ms)
- PDF + Excel report generation with digital signature — entirely on-device
- Hybrid mode support: in-class + remote students in one session via ngrok tunnel

**Speaker notes:**
The lecturer creates a session, gets a PIN, and shows the QR code on the projector.
The dashboard updates live as students register. Reports are generated on the phone
with no server dependency. For hybrid classes, an ngrok tunnel lets remote students
join the same session through a public URL.

**Duration:** 1 min 30 s

---

## SLIDE 8 — Security Design

**Title:** Security — Designed In, Not Bolted On

**Visual:** Threat table:

| Threat | OwHAS Defence |
|---|---|
| Proxy attendance | Face biometric de-duplication |
| Same person, multiple devices | Face descriptor uniqueness check |
| Brute-force PIN guessing | Rate limiter: 10 attempts / 5 min / IP |
| Student leaves early | GPS heartbeat + leftEarly flag |
| Heartbeat replay attacks | Per-student UUID heartbeatToken |
| Face data privacy | In-memory only, never written to disk |
| GPS data privacy | Coordinates discarded after distance check |
| Race condition on registration | Two-phase commit with 5-min TTL token |

**Speaker notes:**
Security was not an afterthought. Each attack vector has a specific countermeasure.
The most important privacy decisions: face data never touches storage,
and GPS coordinates are discarded immediately after the Haversine distance check.

**Duration:** 1 min

---

## SLIDE 9 — Testing & Results

**Title:** Testing Results and Limitations

**Bullets:**

**Results:**
- Captive portal triggered on Android 12, iOS 16, Windows 11 — all passed
- Face de-duplication: 50 registrations, 0 false duplicates passed through
- GPS heartbeat: leftEarly flag set within 1 heartbeat cycle of leaving the radius
- Server IP detection: median 340 ms (767 IPs scanned in parallel)
- 30 simultaneous registrations: no race condition observed

**Limitations:**
- Face recognition accuracy degrades in poor lighting conditions
- GPS accuracy (+/- 15 m) may flag edge cases on classroom boundaries
- Camera requires HTTPS — needs ngrok or mDNS for local deployments

**Speaker notes:**
I tested on real devices, not emulators. The most critical test was 30 students
registering simultaneously from 30 phones on the same hotspot.
No race condition, no duplicate face passed through. The main limitation is
lighting — the face model struggles in very dark environments.

**Duration:** 1 min

---

## SLIDE 10 — Conclusion & Live Demo

**Title:** Conclusion

**Bullets:**
- OwHAS eliminates proxy attendance with no dedicated hardware and no internet dependency
- Captive portal makes registration zero-effort — 30 seconds from connect to registered
- Face biometric de-duplication blocks identity fraud at the moment of registration
- GPS heartbeat enforces sustained presence, not just sign-in
- Deployable on university infrastructure as a permanent VLAN service

**Future directions:**
- NFC tap-in as an alternative for students with camera issues
- Bluetooth LE proximity for GPS-denied environments (basements, shielded rooms)
- Progressive Web App (PWA) for repeat-session convenience

**Call to action:**
"I have a live demo ready. I'll now show a full registration cycle: server startup,
captive portal, face capture, dashboard update, and PDF export."

**Visual:** QR code linking to GitHub repository or demo video.

**Speaker notes:**
OwHAS proves that a robust, biometric attendance system can be built with
commodity hardware — a laptop and a phone. Thank you. I'm happy to take questions
or show the live demo.

**Duration:** 1 min

---

## Demo Script (if time permits — 3 minutes)

1. Start `node server.js` on PC → terminal shows services starting
2. Open Flutter app → "Setup New Session" → fill in course details → Start
3. Connect student phone to hotspot → captive portal notification appears → tap it
4. Student registration: Enter PIN → Face capture → Fill details → "Registered!"
5. Show Flutter dashboard → new student appears → Stats update live
6. (Optional) Second phone → try same face → "Face already registered" rejection
7. Generate and share PDF report

### Q&A Prep

| Likely question | Suggested answer |
|---|---|
| What if a student's camera is broken? | Lecturer can add manually via dashboard — bypasses face check, marked as manual entry |
| How accurate is face recognition? | ~95% accuracy in good lighting with threshold 0.45; degrades in poor light |
| Can students spoof GPS? | Possible but requires knowingly installing a spoofing app |
| Does it work on iPhone? | Yes — captive portal + Safari. Camera needs HTTPS via ngrok or owhas.local |
| Is the face data GDPR compliant? | In-memory only, never stored, discarded when session ends |
