# Presence Recognition — How OwHAS Verifies That Those Present Are Actually Present

This document explains, end-to-end and without code, every mechanism the system uses
to confirm that a student is genuinely and continuously present in the classroom.
The system operates in two distinct modes — **onsite (hotspot)** and **online (school WLAN
with GPS)** — and the depth of verification differs between them.

---

## The Big Picture

Attendance verification in OwHAS is not a single check — it is a layered sequence of
barriers that a student must pass, in order, before they are counted as present. Each
layer targets a different form of potential fraud or error:

| Layer | What it prevents |
|---|---|
| 1. Session PIN | A student cannot register without the lecturer's current secret code |
| 2. GPS geofence at registration *(online only)* | A student cannot register from outside the classroom |
| 3. Device fingerprint | The same physical device cannot register two different people |
| 4. Face scan — uniqueness check | A student cannot send a proxy to register in their place |
| 5. Matricule duplicate check | A student cannot register themselves twice under the same ID |
| 6. Sustained presence *(online only)* | A student cannot leave the classroom after registering |
| 7. Duration threshold | A student cannot register one minute before the session ends and be counted as present |

---

## Part 1 — What the Lecturer Sets Up

Before any student can register, the lecturer launches a session and configures three
values that directly control the verification behaviour:

**Required connection minutes**: the minimum amount of time a student must be
registered and present before they are marked verified (green). A student who registers
but disappears just before this threshold is not counted.

**Grace period minutes**: a short buffer at the end of the session during which
late arrivals can still register (this is a server-side tolerance window, not a bypass
of the other checks).

**Session duration**: how long the attendance window stays open. When this timer
expires, the session closes automatically and no new registrations are accepted.

In online mode, the system also silently captures the lecturer's GPS coordinates at
the exact moment the session is created. This coordinate pair becomes the centre of
the classroom geofence and is used for all subsequent location checks throughout the
session.

---

## Part 2 — The Session PIN (First Gate)

The lecturer's screen shows a four-digit PIN. Students must type this PIN into the
registration screen before anything else happens.

The app sends the PIN to the server and the server looks up whether an active session
exists for that PIN. If no matching active session is found — whether because the PIN
is wrong, the session has not started, or the session has already expired — the
registration process stops immediately and the student sees an error.

This gate ensures that only students who are physically present with their lecturer
(and can see or hear the PIN) can even begin to register. The PIN changes with every
new session.

---

## Part 3 — GPS Geofence at Registration (Online Mode Only)

In online mode, before the student's registration is accepted, the server checks
whether the student is physically inside the classroom boundary.

The student's phone reports its GPS coordinates and the accuracy of those coordinates
at the moment of submission. The server compares the student's location against the
classroom centre captured when the session was created.

The classroom radius is set to **50 metres**. However, GPS on a phone is never
perfectly accurate — it can be off by 10, 20, or more metres. To avoid penalising
students whose phone reports a slightly imprecise location, the system adds the
reported GPS accuracy to the base radius. A student whose phone reports ±30 m
accuracy gets an effective radius of 80 m.

If a student's GPS is extremely inaccurate (worse than 300 m), the geofence check is
waived entirely — the system cannot make a reliable decision and chooses not to
punish the student for their device's hardware limitation.

If the student is genuinely outside the classroom boundary and their GPS accuracy is
good enough to make a reliable judgement, the registration is rejected. The error
message tells the student how far they are from the classroom and asks them to move
closer.

**In onsite (hotspot) mode, this check does not apply.** The simple fact that the
student's phone can reach the lecturer's hotspot is itself proof that they are in
the same physical space.

---

## Part 4 — Device Fingerprint Check (Onsite Mode / Shared Phone Path)

On the hotspot web page and in the shared-phone registration path, the server tracks
the IP address of each registering device. If a device (identified by its IP) has
already registered someone in the current session, and a second person now tries to
register from the same device with different details, the server rejects the
second request.

This prevents one student from registering several classmates on a single phone by
repeatedly submitting the form. Each physical device is allowed to register exactly
one attendee per session.

If the same person submits again from the same device with identical details, the
server recognises it as a harmless duplicate and acknowledges it without creating a
second record.

---

## Part 5 — Face Scan and Anti-Proxy Check (Two-Stage)

This is the core biometric barrier. It operates in two stages that are deliberately
separated to prevent a race condition where two people could submit the same face
simultaneously.

### Stage 1 — Face Descriptor Computation

When the student reaches the face capture step, the app or web page activates the
camera and guides the student to position their face inside an oval guide on screen.
The system uses Google ML Kit's face detection engine to locate the face, then
computes a compact mathematical representation of that face called a **descriptor**.

The descriptor is built from two sources combined:

**Geometric features**: ML Kit maps 36 points along the face outline, 16 points
around each eye, 4 points along the nose bridge, 8 points on the bottom of the nose,
and 10 points along each lip. All these points are normalised relative to the face's
bounding box so that the descriptor is not affected by the student's distance from
the camera or the size of their phone screen. This produces 200 numerical values that
describe the shape and proportions of the face.

**Pixel texture hash**: The face area is cropped from the photo, scaled down to a
16×16 grid, and each of the 256 tiny cells is binarised — recorded as either 0 or 1
depending on whether its brightness is above or below the average brightness of the
face crop. This adds 256 values that capture the texture and tonal distribution of
the face, complementing the geometric measurements.

The final descriptor is a list of 456 numbers that together form a fingerprint of
that individual's face.

### Stage 2 — Uniqueness Verification

The descriptor is sent to the server, which compares it against the descriptor of
every face already registered in the session using **Euclidean distance** (the
straight-line distance between two points in 456-dimensional space). A distance
below the threshold of **0.45** means the two faces are considered the same person.

If the new face is too close to any existing face in the session, registration is
rejected with the message: *"Duplicate face detected — already registered as [name].
Proxy attendance is not allowed."* The student whose name appears in that message is
the one who already registered.

If the face is unique, the server issues a one-time token (valid for 5 minutes) that
the client must present in the next step. This token can only be used once.

### The Two-Stage Design

The token mechanism closes a race-condition window. Without it, two people could
simultaneously pass the uniqueness check — both being compared against the same
stored faces, both appearing unique — and both end up registered. By issuing a
one-time token after the check and re-validating uniqueness at the moment the token
is consumed, the server ensures that the face check and the final commit are atomic.
Even if two requests arrive at the same time, only the first one to consume the token
gets registered; the second finds the token already used.

### The Flutter App's Local Check (Shared Phone Path)

When registration happens on the lecturer's shared phone, the app performs an
additional face uniqueness check *locally*, before even contacting the server. This
uses cosine similarity with a threshold of **0.82** (stricter than the server's
Euclidean check). The two methods are complementary — the local check is fast and
catches obvious duplicates before a network round-trip; the server check is the
authoritative gate.

---

## Part 6 — Sustained Presence via GPS Heartbeat (Online Mode Only)

Passing registration proves the student was in the classroom at the moment they
registered. In online mode, the system continues to verify their presence throughout
the session using a heartbeat mechanism.

### How It Works

After registration, the student's browser starts sending a GPS location report to
the server every **2 minutes**. Each report is paired with the student's secret
heartbeat token — a unique identifier generated at registration time that is never
shown to the student and is not sent to the Flutter dashboard. Only the student's
browser holds this token; it cannot be guessed or forged.

Each heartbeat report carries:
- the student's current GPS coordinates and accuracy
- the secret token (proving the report is from the registered browser session)
- the session PIN

### What the Server Does With Each Heartbeat

The server performs the geofence check again using the same logic as at registration:
50-metre base radius plus the reported GPS accuracy. The outcome determines what
happens to the student's attendance clock:

**If the student is within the classroom boundary**: the server updates the student's
`lastSeen` timestamp to the current time and resets their missed-heartbeat counter.
Their attendance duration continues to grow.

**If the student is outside the classroom boundary**: the server sets a permanent
`leftEarly` flag on the student's record and does not update `lastSeen`. The
attendance duration clock freezes at its current value. This flag is permanent —
even if the student walks back into the classroom and sends another heartbeat, the
system does not unfreeze their clock. Leaving once is treated as leaving for good.

### The Background Timeout Job

To handle the case where a student simply stops sending heartbeats — for example,
their phone dies, they close the browser, or they walk into a dead zone — the server
runs a background job every 2 minutes that scans all active sessions.

Any student whose `lastSeen` timestamp is older than the heartbeat interval plus one
grace period (meaning more than **4 minutes** have passed without a heartbeat) is
automatically flagged as `leftEarly`. Their clock freezes at the last confirmed
value, not at the time the timeout was detected.

The grace period of 1 means a single missed heartbeat is tolerated. The student is
only penalised if they miss two consecutive heartbeats, giving the system resilience
against occasional GPS or network glitches.

### Token Security

The heartbeat token is never exposed in the Flutter dashboard, in the QR code, or
in any URL. It is stripped from the server's response before the attendee list is
sent to the lecturer. A student cannot steal or reuse another student's token because
each token is unique per registration and is stored only in the browser's memory.

---

## Part 7 — Duration Threshold and the Verified Status

Every student on the dashboard has one of two states: **pending** (orange) or
**verified** (green). The state is determined by comparing the student's accumulated
attendance duration against the required connection minutes set by the lecturer.

**Duration in onsite mode**: because the server stores no heartbeat data for hotspot
sessions, the Flutter app computes duration as the time elapsed since the student
registered, using the current clock. Every 5-second dashboard refresh recalculates
this with a fresh timestamp, so the number on screen grows continuously as long as
the session is open.

**Duration in online mode**: the Flutter app computes duration as the difference
between the student's `lastSeen` timestamp and their registration time. Because
`lastSeen` is only updated when a heartbeat arrives and is confirmed in the
classroom, duration grows at most every 2 minutes. If the student has left the
classroom and the `leftEarly` flag is set, `lastSeen` is frozen, and the duration
stops growing at whatever value it reached at the time they left.

The moment the duration crosses the required minutes threshold, the student's tile
turns green. In onsite mode, this is guaranteed to happen eventually as long as the
session remains open. In online mode, it is only guaranteed if the student stays in
the classroom continuously for long enough — a student who leaves early and freezes
at 8 minutes will never be marked verified if the required minimum is 15.

---

## Part 8 — What Each Mode Guarantees

| Guarantee | Onsite (hotspot) | Online (GPS heartbeat) |
|---|---|---|
| Student was in the room at registration | Yes — they can see the hotspot SSID and the PIN | Yes — plus GPS geofence confirms classroom position |
| Student is still in the room later | No — once registered, no further location check | Yes — heartbeats check position every 2 minutes |
| A proxy cannot register for someone | Yes — face uniqueness check at registration | Yes — same face check, plus token binds the browser session |
| The same device cannot register two people | Yes — IP check per session | Yes — same check |
| A student who leaves is penalised | No — their duration keeps growing | Yes — duration clock freezes when `leftEarly` is set |
| A student must meet a minimum time | Yes — duration must reach required minutes | Yes — but the clock can freeze before that threshold |

---

## Summary — The Verification Chain

```
Student enters PIN
    │
    ├── PIN invalid or session expired → rejected
    │
    ▼
[Online only] GPS coordinates checked against classroom
    │
    ├── Outside classroom (and GPS accurate enough) → rejected
    │
    ▼
Device/IP checked against session's registered devices
    │
    ├── Same device already used by someone else → rejected
    │
    ▼
Face scanned → descriptor computed (456 values)
    │
    ├── No face or multiple faces in frame → re-capture required
    │
    ▼
Face descriptor compared to all faces in session
    │
    ├── Distance < 0.45 → duplicate detected → rejected as proxy
    │
    ▼
One-time token issued
    │
    ▼
Matricule checked for duplicates
    │
    ├── Same matricule already registered → silently absorbed (no double entry)
    │
    ▼
Student committed to session — duration clock starts
    │
    ├── [Onsite] Clock grows every 5 seconds until session ends
    │
    └── [Online] Heartbeat sent every 2 min
              │
              ├── In classroom → lastSeen updated → duration grows
              └── Outside classroom or silent for 4 min → leftEarly = true → clock frozen
                        │
                        ▼
              Duration compared to required minutes
                  ├── duration ≥ required → VERIFIED (green)
                  └── duration < required → PENDING (orange)
```
