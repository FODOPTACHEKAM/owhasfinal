# School Wi-Fi (VLAN) Presence Verification — Double-Check Proposals
# Ensuring Students Are in the Classroom, Not Just on the Network

---

## Context — This Is the School Wi-Fi Scenario

This document addresses the **institutional VLAN deployment** of OwHAS,
where students connect to the university's open Wi-Fi network (`ICTU_ATD`)
instead of the lecturer's personal hotspot.

The Node.js server runs at a fixed IP on the VLAN (e.g., `10.50.1.5`).
Sessions are still created without GPS, so the server treats them as offline
sessions — no GPS geofencing, no heartbeat.

---

## The Core Problem with School Wi-Fi

In the **personal hotspot** scenario, the Wi-Fi range is approximately 10–15 metres.
Only students physically in the room can connect to it. Network membership equals
physical presence — the hotspot IS the geofence.

In the **school Wi-Fi (VLAN)** scenario, `ICTU_ATD` is broadcast across the
entire building — corridors, labs, library, canteen, and all classrooms on the
network. A student sitting in the canteen, standing in the corridor, or even
in a different lecture hall can connect to `ICTU_ATD` and register for
attendance just as easily as a student sitting in the target classroom.

```
Personal hotspot:                  School Wi-Fi (ICTU_ATD):
─────────────────────              ──────────────────────────────────
Range ≈ 15 m                       Range = entire building
Connected = in the room ✓          Connected ≠ in the room ✗
Network is the geofence ✓          Network is just campus access ✗
```

This means the current offline model — which relies on LAN proximity as the
presence proof — provides **no classroom-specific guarantee** when the
underlying network is the institutional VLAN.

---

## Two Distinct Gaps

### Gap 1 — Registration from outside the classroom

A student on `ICTU_ATD` anywhere in the building can open a browser, navigate
to the server address, enter the PIN, take a selfie, and register — without
ever entering the lecture hall. The PIN alone proves they received it (from a
friend, from a photo), not that they are physically present.

### Gap 2 — Leaving after registration

A student who does enter the classroom, registers, then leaves immediately
will have their attendance timer running indefinitely. After the required
connection time passes they appear as **Verified** on the lecturer's dashboard
despite having left the room long before the session ended.

---

## What Already Exists (Reusable Infrastructure)

The online GPS heartbeat system is fully built inside the project. Each of the
proposals below reuses parts of it. The heartbeat token, the `lastSeen`
timestamp, the `missedHeartbeats` counter, the `leftEarly` flag, the server
heartbeat endpoint, the background timeout job, and the browser heartbeat
functions in `hotspot.html` are all present and working for the GPS (online)
mode. The only reason they do not run for school Wi-Fi sessions is a single
condition that checks whether a GPS target location was set. Removing or
relaxing that condition unlocks the entire heartbeat infrastructure for the
VLAN scenario as well. However, a connectivity ping without GPS only proves the
phone is still on the network — it does not prove the student is in the room.
The methods below address both gaps.

---

## Method A — Browser Keep-Alive Ping (Closes Gap 2 only)

### What it does

After registration the student's browser sends a silent "still here" request
to the server at a regular interval (every two minutes, matching the online
heartbeat schedule). The server records the timestamp of each successful ping
as `lastSeen`. A background job on the server checks all registered students
periodically. If a student's last ping is older than the expected interval by
a set margin, the server treats them as disconnected: it sets `leftEarly = true`
on their record and freezes their duration clock at the last `lastSeen` value.

From the lecturer's dashboard perspective, a student who left the room and
closed their browser tab (or whose phone disconnected from the VLAN) will
show a frozen duration rather than a continuously growing one, and will be
flagged as having left early.

### What needs to change

On the server side, the heartbeat token must be issued for all sessions, not
just GPS ones. The heartbeat fields (`lastSeen`, `missedHeartbeats`, `leftEarly`)
must be added to each attendee record at registration time. The heartbeat
endpoint must stop rejecting requests that come in without GPS coordinates,
accepting them as valid presence pings for VLAN sessions.

On the browser side, the `_sendHeartbeat()` function must be allowed to send
the ping even when GPS coordinates are unavailable. Currently it aborts if
geolocation is not provided. For the VLAN scenario it should send the ping
with just the session token and matricule, and attach GPS coordinates only if
they happen to be available.

On the Flutter side, the duration calculation must be updated to use `lastSeen`
when the `leftEarly` flag is true, freezing the displayed time instead of
continuing to count from `connectedAt`.

### Limitation

This method proves the student's browser is still open and their phone is still
on the VLAN. It does not prove they are in the classroom. A student who
registered from the corridor and is still sitting in the corridor with their
browser open will pass every ping. This method only closes Gap 2.

| Gap | Solved? |
|---|---|
| Gap 1 — registered from outside the classroom | ✗ Not solved |
| Gap 2 — left after registration | ✓ Solved — clock freezes when browser closes or VLAN disconnects |

---

## Method B — Rolling Challenge Code (Closes Both Gaps — Primary Method)

### What it does

The lecturer generates a **rotating 6-digit code** from the Flutter dashboard
and displays it on the projector screen in the classroom. The code changes
every few minutes. After registration, the student's browser periodically
checks whether a new challenge code is active. When one is, a panel appears
on `hotspot.html` asking the student to type the code they see on the projector.
The student submits the code and the server verifies it against the current
session code.

A student who is outside the classroom cannot see the projector, so they cannot
know the current code. A student who registered and left the room will miss the
next code rotation. If they do not submit the correct code within the rotation
window, their record is flagged.

This is the only proposed method that addresses Gap 1 specifically, because it
requires the student to read something that is only visible from inside the room.

### How it works end to end

When the lecturer decides to run a presence check, they tap a button in the
Flutter app. The app sends the command to the server, which generates a new
random 6-digit code, records it alongside a timestamp, and sets a validity
window (e.g., 5 minutes). The code appears on the Flutter dashboard and is
also expected to be mirrored to the classroom projector.

On `hotspot.html`, each registered student's browser polls the server every
30 seconds to check whether a challenge is active. When one is found and the
student has not yet answered it, a prominent entry panel appears: a numeric
input field, a submit button, and a countdown showing how many seconds remain.
The student types the 6 digits they see on the projector and taps Confirm.
The server checks the submitted code against the active session code, verifies
the window has not expired, and records a `lastChallengePassed` timestamp on
the attendee record along with a running count of challenges passed.

The lecturer's Flutter dashboard can poll the challenge status to see, in real
time, which students have confirmed their presence and which have not responded.
At session end, each attendee record carries a `challengesPassed` count that
the export report can include.

### What the lecturer does in practice

1. Session starts — PIN and QR code shown as normal. Students register.
2. At any point during the lecture, the lecturer taps **"Send Presence Check"** on the dashboard.
3. The 6-digit code appears on the dashboard and the lecturer mirrors it to the projector (or it is shown automatically if the projector is connected).
4. Students have 5 minutes to enter the code on their phones.
5. The dashboard shows a live list: confirmed vs. not yet responded.
6. The lecturer may run another check at the midpoint or end of the session.

### What needs to change

Three new server endpoints are needed: one for the Flutter app to push a new
code, one for the student browser to submit their answer, and one for the
Flutter dashboard to poll who has and has not responded.

Two session-level fields must be added when a session is created: the current
challenge code (initially null, meaning no check is active) and the timestamp
of the last rotation.

In `hotspot.html`, a challenge panel element must be added to the HTML. Three
JavaScript methods are needed: a poller that checks every 30 seconds, a
function that shows the panel and starts a countdown timer when a challenge is
active, and a submission function that sends the entered code to the server.
The poller must be started after registration completes (or after the page
restores a previous registration from localStorage).

| Gap | Solved? |
|---|---|
| Gap 1 — registered from outside the classroom | ✓ Solved — cannot see the projector from outside |
| Gap 2 — left after registration | ✓ Solved — a student who left misses the next challenge |

---

## Method C — Network-Level Device Probing (Closes Gap 2 only)

### What it does

The server periodically sends a TCP connection attempt to the IP address of
each registered student's device on the VLAN. If the device's TCP stack
responds — even with a "connection refused" response — the phone is still on
the network and the server records it as present, updating `lastSeen`. If the
probe times out with no response, the device is gone from the VLAN. After a
set number of consecutive timeouts the attendee is flagged as `leftEarly` and
the duration clock is frozen.

This approach is transparent to the student — they do nothing and see nothing.
It runs entirely on the server side.

### What needs to change

The server needs Node's built-in TCP networking module. A background job runs
every 5 minutes and iterates over all active offline sessions and their
attendees. For each attendee with a valid LAN IP address it opens a short-lived
TCP socket to port 80 on that IP and waits up to 1.5 seconds for a response.
A connection or a "port closed" response means the phone is present; a timeout
means it is gone. After two consecutive timeouts the attendee is marked as
having left early.

No changes are needed to `hotspot.html`. The student does not interact with
this check at all.

### Android Doze mode risk

Android suspends the Wi-Fi radio after 2–3 minutes of screen inactivity. A
student sitting quietly in class with their phone face-down may fail the TCP
probe not because they left but because Android put their radio to sleep. This
creates false positives — students marked as left who are actually present.

The mitigation is to combine Method C with Method A. When the browser is
sending heartbeat pings, Android treats the network as active and does not
suspend the radio. With both methods running, the TCP probe becomes a backup
signal rather than the primary one, so a single Doze event does not
incorrectly freeze a student's clock.

| Gap | Solved? |
|---|---|
| Gap 1 — registered from outside the classroom | ✗ Not solved — VLAN is building-wide |
| Gap 2 — left after registration | ✓ Solved — probe detects network disconnection |

---

## Method D — Mid-Session Face Re-Verification (Closes Gap 2 + Anti-Proxy)

### What it does

The lecturer triggers a face identity check from the Flutter dashboard during
the session. When triggered, each registered student's browser detects an
active challenge and prompts them to retake a selfie — the same camera flow
used at registration. The new face descriptor is sent to the server, which
compares it against the descriptor stored when the student first registered,
using the same 0.45 Euclidean distance threshold. If the two descriptors are
close enough, the student's identity is confirmed and attendance continues. If
the distance exceeds the threshold, the server freezes the student's duration
clock and marks their record as having failed the face check.

This method specifically addresses a scenario unique to the school Wi-Fi
context: a student registers themselves, then leaves their phone with a friend
who stays in the classroom. The friend can keep the browser open and respond
to browser pings (defeating Methods A and C), but they cannot pass a face
re-verification because their face descriptor will not match the registered
student's.

### What needs to change

Three new server endpoints are needed: one for Flutter to trigger the check,
one for the browser to submit the new descriptor, and one for the dashboard
to poll who has passed or failed.

A `faceChallenge` object must be added to the session when a check is triggered,
recording the timestamp and a validity window. The object also stores the
submissions received so the status endpoint can report them.

In `hotspot.html`, a background poller must check every 30 seconds whether a
face challenge is active for the session. When one is found and the student
has not yet responded, the face capture section is shown again — reusing the
existing `FacePhotoManager` and camera setup from the original registration
step. Once the selfie is taken, instead of submitting to the normal registration
endpoint, the descriptor is sent to the face re-check endpoint. On success, the
success screen is restored. On failure, the student is shown an error and their
record is frozen.

### Limitation

If a student registered from outside the classroom (Gap 1) and is still outside,
they would need to retake a selfie from wherever they are. Their face would
still match if they are the same person — so this method does not independently
solve Gap 1. It only confirms identity, not location.

| Gap | Solved? |
|---|---|
| Gap 1 — registered from outside the classroom | Partial — confirms identity, not location |
| Gap 2 — left after registration (student leaves their own phone) | ✗ Phone left in class → friend passes ping but fails face |
| Gap 2 — left but gave phone to a friend | ✓ Solved — friend's face does not match registration |

---

## Summary Comparison

| | Method A: Browser Ping | Method B: Challenge Code | Method C: Network Probe | Method D: Face Re-check |
|---|---|---|---|---|
| Closes Gap 1 (outside classroom) | ✗ | ✓ Can't see projector | ✗ | Partial |
| Closes Gap 2 (left after registering) | ✓ Browser must stay open | ✓ Missed challenge = flagged | ✓ Device must stay on VLAN | ✓ |
| Proof of "same person" | ✗ | ✗ | ✗ | ✓ |
| Student action required | None | Enter 6-digit code (~30 s) | None | Retake selfie (~30 s) |
| Disrupts lecture | None | Slightly (1–2 times/session) | None | More (camera re-open) |
| Works if phone screen is off | ✗ Doze risk | ✓ | ✗ Doze risk | ✓ |
| Implementation effort | Very low | Medium | Medium | High |
| Covers the school Wi-Fi gap? | No — only Gap 2 | **Yes — both gaps** | No — only Gap 2 | Partial |

---

## Best Double Verification for School Wi-Fi

The four methods above each address part of the problem. None of them alone is
sufficient. The strongest solution is a layered approach where two mechanisms
cover Gap 1 and Gap 2 independently, so neither gap can be exploited even if
one layer is bypassed or fails.

The recommended combination is built around one core insight: **Gap 1 must be
closed at the moment of registration, not after it.** If a student can register
from outside the classroom and then be asked a challenge code later, they have
already been committed to the attendee list. The challenge code is then
corrective, not preventive. Closing Gap 1 before registration is committed is
a stronger guarantee.

---

### Layer 1 — Two-Factor Registration Gate (closes Gap 1 at the source)

The current registration step requires only a PIN. The PIN is announced to the
whole class and can easily be passed to someone outside via message. The fix is
to require a **second factor at the PIN step itself** — one that is only visible
from inside the room.

When the session starts, the Flutter dashboard generates a short rotating code
— separate from the session PIN — and displays it prominently on the projector.
This code changes every three minutes. A student opening `hotspot.html` must
enter both the session PIN and the current projector code before the server
accepts their registration. The server validates both at once: PIN identifies
the session, projector code confirms physical presence at the projector.

A student who is not in the room cannot see the projector code. A student who
received the PIN from a friend via message cannot also receive the projector
code in time, because it changes every three minutes and there is no way to
relay a live rotating code reliably during a lecture. Even if one code is
shared, it expires before a second person can use it from outside.

This does not replace the existing PIN. It adds one field to the existing Step 0
— the student enters the PIN and the projector code together. The server checks
both. If either is wrong or expired, registration is refused. The change to the
registration form is minimal and the student experience adds only a few seconds.

This is the most important layer. It means that by the time a student's record
is committed to the session, the system has already confirmed they were
physically in the room.

---

### Layer 2 — Browser Heartbeat Ping (closes Gap 2 continuously)

Once registered, the student's browser sends a silent ping to the server every
two minutes. The server records the timestamp of each successful ping. If pings
stop — because the student closed the browser tab, left the VLAN, or turned off
their phone — the server's background job detects the gap and freezes the
student's attendance clock at the last confirmed ping. The student is flagged as
having left early, and their duration on the final report reflects only the time
they were actually present.

This layer runs automatically with no action required from the student or the
lecturer. It is always active after registration. It reuses the entire existing
heartbeat infrastructure already built for the online GPS mode — the only change
needed is to issue a heartbeat token for VLAN sessions as well as GPS sessions.

Layer 2 alone would not stop a student from registering outside the room, which
is why Layer 1 must come first. But once a student has legitimately registered
through the two-factor gate, Layer 2 is the continuous enforcement that prevents
them from earning attendance time they did not actually spend in the session.

---

### Layer 3 — Mid-Session Challenge Code (optional, high-stakes sessions)

For sessions where stricter enforcement is needed — graded labs, exams, or any
session where the lecturer suspects students have left — a mid-session challenge
code provides an additional in-room confirmation during the session rather than
just at registration.

The lecturer triggers a new projector code from the Flutter dashboard during
the lecture. Students have a fixed window (five minutes) to read the code from
the projector and enter it in their browser. Students who do not respond within
the window are flagged. The dashboard shows the lecturer in real time who has
and has not confirmed.

This layer is not required for every session. For a standard lecture, Layers 1
and 2 provide sufficient assurance. Layer 3 is the escalation option when the
lecturer wants spot-confirmation that students are still in the room at a
specific point during the session.

---

### Layer 4 — Face Re-Verification (optional, proxy-specific threat)

If the specific concern is proxy attendance — a student registering legitimately
but then leaving their phone with a friend who stays — neither the heartbeat
ping nor the challenge code can detect this, because the friend can answer both
on behalf of the registered student. Face re-verification closes this specific
hole by requiring a selfie that is compared against the registration descriptor.
The friend's face will not match at the 0.45 threshold.

This layer is reserved for the highest-stakes sessions only, because it
disrupts the lecture (students must retake a selfie) and adds complexity to the
server.

---

### How the Layers Work Together in a Normal Session

The session starts. The projector displays the rotating code alongside the
session PIN. Students arrive, see both on the projector, enter both in
`hotspot.html`, take their selfie, fill in their details, and register. The
two-factor gate ensures only students in the room can complete Step 0. After
registration the browser starts sending heartbeat pings automatically. Students
who leave and close their browser are flagged by the background job. The
lecturer ends the session when class finishes. The exported report shows each
student's duration (live or frozen) and whether they were flagged.

For a high-stakes session the lecturer additionally triggers a mid-session
challenge code at the halfway point, and optionally a face re-check for any
student who did not respond to the challenge.

---

## Best Propositions Summary Table

| Proposition | Closes Gap 1 (outside classroom) | Closes Gap 2 (left after registering) | Student action | Lecturer action | When to use |
|---|---|---|---|---|---|
| **Two-factor registration gate** (PIN + rotating projector code) | ✅ Yes — projector code visible only from inside room | ✗ No — only applies at registration | Enter one extra code at Step 0 | Display code on projector (automatic) | **Every session — this is the core fix** |
| **Browser heartbeat ping** | ✗ No | ✅ Yes — clock freezes on disconnect | None — fully automatic | None | **Every session — runs in background** |
| **Mid-session challenge code** | ✅ Yes — re-confirms presence during session | ✅ Yes — missed challenge flags the student | Enter 6-digit code when prompted | Tap "Send Presence Check" in app | High-stakes or suspicious sessions |
| **Face re-verification** | ✗ Partial — confirms identity, not location | ✅ Yes — catches phone left with a friend | Retake selfie when prompted | Tap "Send Face Check" in app | Exams, graded labs only |
| **Network probe (TCP)** | ✗ No | ✅ Yes — detects VLAN disconnection | None | None | Optional backup alongside heartbeat |

### Verdict by Session Type

| Session type | Recommended layers |
|---|---|
| Standard lecture | Layer 1 (two-factor gate) + Layer 2 (heartbeat) |
| Graded lab or test | Layer 1 + Layer 2 + Layer 3 (mid-session challenge) |
| Formal exam | Layer 1 + Layer 2 + Layer 3 + Layer 4 (face re-check) |

### Why This Combination Is the Strongest

The two-factor registration gate is the only mechanism that prevents a fraudulent
registration from being committed in the first place. Every other method reacts
after the fact — flagging a student who has already been recorded as present.
The gate removes the fraudulent entry before it exists.

The heartbeat ping is the only continuous enforcement mechanism that runs without
any action from the student or the lecturer. It does not rely on the lecturer
remembering to send a challenge. It works silently and automatically for the
entire duration of the session.

Together, the gate closes the entry point and the heartbeat closes the exit
point. A student must be in the room to register, and must remain connected to
stay verified. These two layers cover both gaps for every session with minimal
disruption, minimal implementation effort, and no change to the student's
experience beyond one extra field at Step 0.
