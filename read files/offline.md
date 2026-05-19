# How OwHAS Offline Mode Works — From PIN Entry to Session End

---

## Overview

Offline mode is the default operating mode of OwHAS. It requires no internet
connection. The lecturer's PC runs `node server.js`, enables its Windows Mobile
Hotspot, and becomes both the network access point and the attendance server.

**The key principle:**
> Being connected to the lecturer's Wi-Fi hotspot *is* physical presence in the classroom.
> No GPS is needed because the network itself is the geofence.

---

## Part 1 — What Makes a Session "Offline"

When the lecturer starts a session, the Flutter app calls `POST /api/session-init`.
In offline mode, no GPS coordinates are sent (the lecturer does not have an active
online session). The server stores:

```javascript
targetLocation: null    // ← this is the offline flag
```

Every security check in the server (`/api/biometric-connect`, `/api/heartbeat`,
`/connect`) tests for `session.targetLocation` before enforcing GPS. When it is
`null`, all GPS checks are skipped entirely.

```javascript
// server.js — /api/biometric-connect
if (session.targetLocation) {         // ← only runs for online sessions
    if (latitude === undefined ...)
        return res.status(403).send('GPS required');
    ...
}
// Offline: falls through — no GPS check at all
```

Also, the heartbeat token is never issued for offline sessions:

```javascript
const isOnlineSession = !!session.targetLocation;   // false for offline
const heartbeatToken  = isOnlineSession ? randomUUID() : null;
// Response to browser: heartbeatToken is absent → browser never starts the loop
```

---

## Part 2 — What the Student Does After Connecting

When a student connects their phone to the lecturer's hotspot:

1. The captive portal (port 80) intercepts the OS connectivity probe.
2. A "Sign in to network" notification appears on the phone.
3. The student taps it → `hotspot.html` opens automatically in the phone's browser.

Alternatively, the lecturer shows the QR code on the projector and the student
scans it to open the same page.

---

## Part 3 — The 3-Step Registration Flow in Detail

### Step 0 — PIN Entry

The student sees a 4-digit numeric field. They type the PIN the lecturer displayed
on the dashboard (or announced verbally).

**What the page sends:**
```javascript
POST /api/validate-pin
{ "pin": "3741" }
```

**What the server checks:**
```javascript
// server.js — /api/validate-pin
const session = getSessionByPin(pin);   // looks up the active session
if (!session) return res.status(404).json({ error: 'Invalid or expired PIN' });
// Session not found → PIN wrong, session ended, or session expired
```

The server also checks whether the session has expired (it deletes it on the
next lookup if `new Date() > session.expiresAt`).

**What the server returns on success:**
```json
{
  "valid": true,
  "courseName": "Computer Networks",
  "courseCode": "CN3010",
  "lecturerId": "device-abc123",
  "lecturerName": "Dr. Nguimfack"
}
```

The page displays the course name below the PIN field so the student can
confirm they are in the right class. The stepper pill advances to step 1.

**Rate limiting:** `pinLimiter` allows 10 wrong PIN attempts per IP per 5
minutes. After that, the server returns HTTP 429 and the student must wait.

---

### Step 1 — Face Capture and Verification

The student taps "Take Photo". The camera opens (native camera app on mobile,
live webcam on desktop HTTPS). They take a selfie.

**What the browser does locally (no network call yet):**

face-api.js runs five models sequentially in the browser:
1. `TinyFaceDetector` — locates the face in the photo
2. `FaceLandmark68Net` — marks 68 landmark points (eyes, nose, jaw, mouth)
3. `FaceRecognitionNet` — produces the 128-dimension identity descriptor
4. `AgeGenderNet` — estimates age and gender
5. `FaceExpressionNet` — scores 7 expression classes (neutral, happy, etc.)

The 128-dimension descriptor is a vector of floating-point numbers that
uniquely encodes the person's facial geometry.

**What the page sends:**
```javascript
POST /api/verify-face
{
  "pin": "3741",
  "descriptor": [0.142, -0.031, 0.896, ...]  // 128 numbers
}
```

**What the server checks:**
```javascript
// server.js — /api/verify-face
const THRESHOLD = 0.45;
for (const entry of session.faceDescriptors) {
    // Euclidean distance < 0.45 → same face → proxy detected
    if (faceDistance(descriptor, entry.descriptor) < THRESHOLD) {
        return res.json({ unique: false, matchedName: entry.name });
    }
}
// No match found → face is new to this session
const faceId = randomUUID();
session.pendingFaces.set(faceId, { descriptor, reservedAt: new Date(), used: false });
return res.json({ unique: true, faceId });
```

If a duplicate is detected:
- The page shows: `"This face is already registered under 'Ivan Jordan'. Proxy attendance is not allowed."`
- The student cannot proceed.

If unique:
- The server issues a **one-time `faceId` token** valid for 5 minutes.
- The page stores this token in memory for use in step 2.
- The page shows the biometric summary: `"Face verified ✓  ~22 yr · male · neutral"`
- The stepper advances to step 2.

The `faceId` token is single-use. If a second student tries to submit the
same `faceId`, the server returns 403. If the token is not used within
5 minutes, it is cleaned up by a periodic server job:

```javascript
// Runs every 60 seconds
setInterval(() => {
    for (const [id, entry] of session.pendingFaces.entries()) {
        if (entry.used || Date.now() - entry.reservedAt.getTime() > FIVE_MIN)
            session.pendingFaces.delete(id);
    }
}, 60_000);
```

---

### Step 2 — Personal Details Form

The student fills in:
- Full Name (2–100 characters)
- Student ID / Matricule (4–30 alphanumeric characters)
- Email address

**What the page sends on "Register for Attendance":**

```javascript
POST /api/biometric-connect
{
  "username":      "Ivan Jordan",
  "matricule":     "FE22T0042",
  "email":         "ivan@university.cm",
  "sessionPin":    "3741",          // or sessionToken for QR path
  "faceId":        "a1b2c3d4-...", // one-time token from step 1
  "faceBiometrics": {              // full biometric profile
      "age":                22,
      "gender":             "male",
      "genderProbability":  0.972,
      "dominantExpression": "neutral",
      "expressionScore":    0.874,
      "expressions":        { "neutral": 0.874, "happy": 0.063, ... },
      "detectionScore":     0.981,
      "faceBox":            { "x": 112, "y": 74, "width": 196, "height": 240 }
  }
  // latitude and longitude are NOT sent in offline mode
}
```

**What the server does (in order):**

1. **Validates input** — name, matricule, email present and within length limits.
2. **Validates the faceId token** — must exist, must not be used, must not be
   older than 5 minutes.
3. **Race-condition guard** — re-checks descriptor uniqueness at commit time
   (prevents two simultaneous identical requests both passing step 1).
4. **Matricule duplicate check** — rejects if the same matricule is already in
   `session.attendees`.
5. **GPS check** — skipped because `session.targetLocation === null`.
6. **Commits the record:**

```javascript
// Mark the faceId token as used (single-use)
pending.used = true;

// No heartbeat for offline sessions
const isOnlineSession = !!session.targetLocation;   // false
const heartbeatToken  = null;                       // never issued

// Store the face descriptor for future duplicate checks
session.faceDescriptors.push({
    faceId, matricule, name: username, descriptor: pending.descriptor, registeredAt: connectedAt,
});

// Store the attendee record
session.attendees.push({
    username, matricule, email,
    ip:           studentIP,      // device IP — used as offline fingerprint
    faceId,
    faceVerified: true,
    connectedAt:  new Date().toISOString(),
    biometrics:   bio,            // sanitised face profile (age, gender, etc.)
    time:         new Date().toLocaleString(),
    // lastSeen, heartbeatToken, missedHeartbeats, leftEarly are NOT added
});
```

7. **Returns:**
```json
{
  "ok": true,
  "message": "Successfully registered for Computer Networks!"
}
```

Note: no `heartbeatToken` in the response. The browser checks for its presence
and, finding none, skips the heartbeat loop entirely.

---

## Part 4 — What the Student Sees After Registration

After a successful offline registration:

1. The page transitions to the **registered success screen** — the PIN form,
   face section, and details form are all hidden. The student sees:
   ```
   ✓
   Hi, Ivan Jordan!
   Computer Networks · CN3010
   Keep this page open to confirm attendance.
   ```

2. The status panel below shows:
   ```
   • Ivan Jordan — Registered ✓  Keep this page open.
     Your location is confirmed every 2 min to verify attendance.
   ```
   (The pulsing green dot and heartbeat message are shown for visual
   consistency, but no GPS pings are actually sent in offline mode.)

3. The registration state is saved to `localStorage`:
   ```javascript
   localStorage.setItem('owhas_reg', JSON.stringify({
       name:          'Ivan Jordan',
       courseName:    'Computer Networks',
       courseCode:    'CN3010',
       heartbeatToken: null,    // null for offline
       matricule:     'FE22T0042',
       pin:           '3741',
       savedAt:       Date.now(),
   }));
   ```

   If the student accidentally reloads the page, `_tryRestoreRegistration()`
   reads `localStorage`, finds `heartbeatToken: null`, and goes directly to
   the success screen without showing the PIN form again. The 24-hour TTL
   prevents stale state from persisting across classroom sessions.

---

## Part 5 — How Duration Is Tracked in Offline Mode

The Flutter dashboard polls `GET /api/attendees?pin=3741` every 5 seconds.
The server returns each attendee's `connectedAt` timestamp. The app computes:

```dart
// AttendanceProvider._convertServerAttendees()
final joinedAt       = DateTime.parse(attendee['connectedAt']);
final durationMinutes = DateTime.now().difference(joinedAt).inMinutes;
final isVerified     = durationMinutes >= requiredConnectionMinutes;
```

There is no `lastSeen` field on offline attendees. The duration grows
continuously as real time passes from `connectedAt`. The status chip
flips from **Pending** to **Verified** once `durationMinutes >= requiredConnectionMinutes`.

**Why this is valid for offline mode:**

The hotspot is a hard physical boundary. To keep the timer running, the
student must:
- Stay within Wi-Fi range of the lecturer's PC.
- Keep the browser tab open (closing the tab does not affect the timer, but
  leaving Wi-Fi range cuts their network access).

The key enforcement is that students **cannot re-register**. Once committed:
- Their **IP address** is stored. A second registration attempt from the same
  device returns HTTP 200 "You are already registered" without a new record.
- Their **face descriptor** is stored. A second selfie from the same person
  is rejected at `POST /api/verify-face` (distance < 0.45 → duplicate).

So leaving the room and returning does not let a student "reset" their timer —
they are permanently tied to their original `connectedAt`. Their timer ran
the whole time they were gone.

---

## Part 6 — IP Fingerprinting (Offline-Specific Security)

In offline mode, the student's IP address on the local LAN is used as a
device fingerprint. The server stores it on every `POST /connect` (Flutter
app path) and `POST /api/biometric-connect` (browser path):

```javascript
const studentIP = req.headers['x-forwarded-for'] || req.ip || req.socket.remoteAddress;
// ...
session.attendees.push({ ..., ip: studentIP, ... });
```

Before committing a new record, the server checks:
```javascript
// /connect endpoint
const existingEntry = session.attendees.find(a => a.ip === studentIP);
if (existingEntry) {
    if (existingEntry.username !== username || existingEntry.matricule !== matricule)
        return res.status(403).send("Device already registered under a different name.");
    return res.status(200).send("You are already registered for this session!");
}
```

On the `biometric-connect` endpoint the matricule check serves the same role.
Combined with the face check, the two barriers are:

| Barrier | Blocks |
|---|---|
| Face descriptor (Euclidean distance < 0.45) | Different person registering for the same student |
| IP / matricule duplicate check | Same person or same device trying to register twice |

---

## Part 7 — Session Lifecycle for Offline Mode

```
Lecturer opens Flutter app
        ↓
Taps "New Session" → fills in course, duration, grace period
        ↓
App calls POST /api/session-init  (no GPS → targetLocation = null)
        ↓
Server creates session: { PIN: "3741", expiresAt: now+duration, targetLocation: null }
        ↓
PIN shown on dashboard + QR code displayed
        ↓
Students connect to hotspot → captive portal → hotspot.html
        ↓
Each student: PIN ─► face verify ─► personal details ─► committed to session.attendees
        ↓
Dashboard polls /api/attendees every 5 s
durationMinutes = now - connectedAt; isVerified = durationMinutes >= requiredConnectionMinutes
        ↓
Lecturer taps "End Session"
        ↓
App calls POST /api/end-session → activeSessions.delete(pin) → sessions.json updated
        ↓
Flutter generates PDF / Excel report locally (no server call)
        ↓
Report shared via native share dialog or saved to Downloads
```

**Session expiry (automatic):**
The session has a fixed `expiresAt = createdAt + durationMinutes`. After that
time, `getSessionByPin()` deletes it on the next lookup. Students who attempt
to register after the session expires receive HTTP 404 "Session not found".

**Server restart recovery:**
At startup, the server loads `sessions.json` and restores any sessions whose
`expiresAt` has not yet passed. A student who registered before a crash is
still in the restored attendee list.

---

## Part 8 — What Offline Mode Does NOT Do

| Feature | Offline | Why absent |
|---|---|---|
| GPS check at registration | ✗ | LAN proximity is the geofence; GPS adds nothing |
| GPS heartbeat loop | ✗ | No `heartbeatToken` issued; browser never starts the loop |
| `lastSeen` field on attendee | ✗ | Duration uses `now - connectedAt` (wall clock) instead |
| `leftEarly` flag | ✗ | Only set by heartbeat timeout; irrelevant offline |
| Re-validation after registration | ✗ | Not needed; hotspot disconnection is the enforcement |

---

## Part 9 — Comparison: Offline vs Online Duration Enforcement

| Scenario | Offline | Online |
|---|---|---|
| Student registers then stays | Timer grows ✓ Wall clock | Timer grows ✓ Heartbeat `lastSeen` |
| Student registers then leaves | Timer still grows (but cannot re-register) ⚠ | Timer freezes after missed heartbeats ✓ |
| Student registers then leaves Wi-Fi range | Network lost — they can see the problem themselves | GPS out of range → `leftEarly=true`, clock frozen ✓ |
| Student tries to register twice | Blocked by IP + face descriptor ✓ | Blocked by matricule + face descriptor ✓ |
| Student submits for a friend | Blocked by face check (descriptor < 0.45 → reject) ✓ | Blocked by face check ✓ |

The offline model's one gap — a student who leaves physically while their
timer keeps running — is acceptable because:
1. They cannot come back and re-register.
2. The lecturer can see their physical absence in the room.
3. For formal enforcement, the lecturer ends the session when class ends,
   so no extra time accumulates beyond what actually happened.
