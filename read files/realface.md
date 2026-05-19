# Integrating OpenCV into OwHAS — Face Verification for Online and Offline Modes

---

## Overview

The current OwHAS face pipeline runs entirely inside the student's browser using
face-api.js. The browser captures a selfie, extracts a 128-dimension descriptor,
and sends only that descriptor to the server. The server never sees the actual
photo — it only compares two arrays of floating-point numbers.

This design is lightweight and requires no special software on the server, but it
has two fundamental weaknesses:

1. **No liveness check.** The browser cannot tell whether the student held up a
   photo of someone else, showed a face on another phone screen, or used a printed
   picture. Any image that produces a matching descriptor passes the check.

2. **Client-side trust.** The descriptor is computed on the student's own device.
   A technically capable student could intercept the request and substitute a
   pre-computed descriptor from a different person's photo.

OpenCV addresses both weaknesses by moving face analysis to the **server side**,
where the student cannot tamper with the computation, and by enabling liveness
detection techniques that are not available in browser-based face-api.js.

---

## What OpenCV Brings to the Project

### Liveness detection

OpenCV can detect whether the face in the image is a real, living person or a
spoofed representation. The main techniques are:

- **Blink detection** — the server requests that the student blink during capture.
  OpenCV tracks the Eye Aspect Ratio (EAR) across a short sequence of frames.
  A real eye blinks; a printed photo or screen does not change at all.

- **Head movement** — the server requests a slight head turn (left, right, or nod).
  OpenCV tracks facial landmarks across frames and confirms the head actually moved
  in three-dimensional space. A flat image cannot simulate genuine 3D movement.

- **Texture analysis** — OpenCV can analyse the micro-texture of the skin in the
  image. A real face has fine pores, subtle colour variation, and natural surface
  texture. A printed photo or phone screen has a uniform, artificially smooth
  surface. Algorithms such as Local Binary Pattern Histogram (LBPH) can distinguish
  the two with high accuracy.

- **Depth inconsistency** — a camera pointed at a flat object (a photo held in
  front of it) will show the face at a single uniform depth. A real face has a
  nose that protrudes, eyes that are set back, and a chin that recedes. OpenCV can
  infer this depth map from a regular camera through stereo or motion cues.

### Server-side descriptor computation

Instead of trusting the descriptor the browser sends, the server receives the
**raw image** and recomputes the descriptor itself using OpenCV's face recognition
module (for example the DNN-based FaceNet model or the built-in
`FaceRecognizerSF`). The descriptor produced on the server is compared against the
stored registration descriptor. Because the computation happens on the server, the
student has no way to inject a pre-crafted descriptor.

### Higher accuracy face matching

OpenCV's face recognition models — including LBPH, EigenFaces, Fisherfaces, and
DNN-based models — can be tuned specifically for the lighting conditions and
camera quality expected in a university classroom. The server can also reject
images that are too dark, too blurry, or taken at too steep an angle before
attempting a match.

---

## Where OpenCV Runs

OpenCV is a native C++ library with bindings for Python and, to a lesser extent,
Node.js. The two realistic integration paths for OwHAS are:

### Option 1 — Python microservice alongside server.js

A small Python process runs on the same machine as server.js. When a face needs
to be verified, server.js forwards the image to this Python process over a local
HTTP connection (loopback only, never exposed to students). The Python process runs
OpenCV, performs liveness detection and descriptor computation, and returns a
structured result. server.js receives the result and continues its existing
validation logic.

This approach keeps the Node.js server exactly as it is. The Python process is a
separate, replaceable component. Python's OpenCV bindings (`cv2`) are the most
mature and best documented, and virtually all liveness detection tutorials and
models are written for Python.

### Option 2 — Node.js OpenCV binding (`opencv4nodejs`)

`opencv4nodejs` exposes OpenCV functions directly inside Node.js. server.js can
call face detection and recognition functions without spawning a separate process.
The advantage is simplicity — one process, one language. The disadvantage is that
`opencv4nodejs` requires compiling native C++ modules, which is more complex to
install and can break when Node.js or the operating system is updated.

For the VLAN scenario, where the server runs as a fixed machine on the school
network, Option 1 (Python microservice) is the more practical choice because
Python and OpenCV have a straightforward installation path and are easier to
maintain than native Node.js bindings.

For the online scenario, where the server runs in a Linux cloud environment,
either option works, though Option 1 remains simpler to maintain.

---

## How OpenCV Integrates into the Registration Flow

The existing two-phase registration flow (face verify → biometric connect) maps
cleanly onto the OpenCV integration:

### Phase 1 — `/api/verify-face` with OpenCV

Currently the browser sends a 128-dimension descriptor. With OpenCV, the browser
sends the **raw image** (as a base64-encoded JPEG or PNG). The server passes the
image to the OpenCV pipeline, which:

1. Detects whether a face is present and whether it is large enough to be reliable.
2. Rejects the image if quality is insufficient (blur, darkness, angle).
3. Runs the liveness challenge — either a blink check (if the browser sends a short
   video clip or burst of frames) or a texture analysis check (if only a single
   frame is sent).
4. Extracts the face descriptor using the server-side recognition model.
5. Compares the descriptor against all existing descriptors in the session to detect
   proxy attempts, using the same 0.45 threshold logic already in server.js.

If all checks pass, the server issues the one-time `faceId` token as it does now.
If liveness fails, the server returns a specific error — "We detected a photo or
screen — please use a live selfie" — and the student must try again.

### Phase 2 — `/api/biometric-connect`

This phase does not change architecturally. The `faceId` token is still consumed
here in a single-use, time-limited transaction. The difference is that the token
was issued only after server-side liveness passed, so the guarantee it carries is
stronger.

---

## VLAN Mode (School Wi-Fi — ICTU_ATD)

In VLAN mode the server runs as a fixed machine on the school network at a
dedicated IP address (`10.50.1.5`). The OpenCV pipeline runs on that same server.
Because the VLAN is a closed institutional network, images travel only between
student phones and the school server — they never leave the campus network.

### What changes for offline

The browser must send the image rather than the descriptor. This increases the
payload size. A compressed JPEG selfie at reasonable quality is typically 60–150 KB,
which travels over Wi-Fi in under a second on a local LAN. The additional server
processing time for liveness detection adds roughly 200–500 milliseconds depending
on the server hardware. From the student's perspective, the face step takes slightly
longer before the confirmation appears.

### Liveness approach for offline

Because VLAN sessions run on the school server which may have modest processing
resources, the recommended liveness approach is **texture analysis on a single frame** rather
than a multi-frame blink sequence. Texture analysis requires one image, runs in
under 300 milliseconds, and does not require the student to perform any action
(no blinking, no head movement). It catches the most common spoofing attempts —
a printed photo or a face shown on another phone screen — without slowing down
a classroom of 30–40 students registering simultaneously.

For higher security offline sessions (such as a graded lab), the multi-frame
blink detection can be enabled. The browser captures a short burst of 10–15
frames (about one second of video) during the face step, compresses them, and
sends the burst to the server. OpenCV processes each frame and confirms a genuine
blink occurred. This is slower but defeats all passive spoofing methods.

### What does NOT change for VLAN mode

The session model, the PIN flow, the faceId token, the attendee record, the
IP fingerprinting, and the duration calculation are all unchanged. OpenCV is
inserted only at the face analysis stage — everything before and after it stays
the same.

---

## Online Mode (Cloud Server with GPS)

In online mode the server runs in a cloud environment (Linux). The OpenCV
pipeline runs on the cloud server. The student's image is transmitted over the
internet to the server rather than over a local LAN.

### Image transmission consideration

Sending a raw image over the internet requires the browser to use HTTPS to
protect the image in transit. The online server already requires HTTPS for the
GPS heartbeat, so this is already in place. The image payload size (60–150 KB)
is small compared to what modern mobile browsers routinely upload.

### Liveness approach for online

On the cloud server, CPU is more plentiful and the latency budget is more flexible
because the GPS heartbeat already introduces round-trip delays. Multi-frame blink
detection is practical in online mode. The browser can capture a 15-frame burst,
send it to the server, and receive the result within 1–2 seconds on a typical
mobile connection. Texture analysis can also run as a second layer: both checks
must pass before the `faceId` token is issued.

The combined check — texture analysis confirming a real surface plus blink
detection confirming a live eye — makes spoofing extremely difficult in practice.

### How OpenCV interacts with GPS verification in online mode

The existing GPS check at `/api/biometric-connect` is independent of the face
pipeline. OpenCV runs during the face verification phase (`/api/verify-face`) and
the GPS check runs at the final commit phase (`/api/biometric-connect`). The two
checks happen at different stages and do not interfere with each other. Both must
pass for attendance to be committed.

---

## What the Student Experiences with OpenCV Enabled

### Without liveness (texture analysis only — recommended for VLAN mode)

The face step looks identical to the current flow from the student's perspective.
They tap "Take Photo", take a selfie, and wait. The only visible difference is
that the server's response takes a fraction of a second longer. If spoofing is
detected, they see a clear error message instead of proceeding.

### With blink detection

The face step now has an instruction: **"When the camera is ready, blink once."**
The browser opens the camera, counts down, and records a short burst of frames.
The student blinks naturally. The server checks for the blink and either confirms
the face or asks the student to try again. Students who are used to face unlock
on their phones will find this familiar.

### With head movement

The instruction reads: **"When ready, slowly turn your head to the right."** The
process is the same as blink detection. This check is slightly more disruptive for
a large class but is the hardest liveness method to fool because it requires
realistic 3D head geometry.

---

## What Stays Exactly the Same

Regardless of which OpenCV liveness method is chosen or whether OpenCV is added
at all:

- The session model and PIN flow are unchanged.
- The `faceId` one-time token concept is unchanged.
- The 0.45 Euclidean distance threshold for duplicate/proxy detection is unchanged.
- The attendee record schema is unchanged (OpenCV may add a `livenessScore` field
  but all existing fields remain).
- The Flutter dashboard, the heartbeat system, and the export report are unchanged.
- The offline vs online logic in server.js is unchanged — OpenCV is called by the
  face verification endpoint regardless of whether `targetLocation` is null or not.

---

## Summary — Online vs Offline OpenCV Comparison

| Aspect | VLAN Mode (ICTU_ATD) | Online (cloud + GPS) |
|---|---|---|
| Where OpenCV runs | School VLAN server (`10.50.1.5`) | Linux cloud server |
| Integration approach | Python microservice (recommended) | Python microservice or Docker |
| Liveness method | Texture analysis (fast, single frame) | Texture + blink detection |
| Image transmitted over | School LAN only | HTTPS over internet |
| Processing time added | ~200–300 ms | ~500–1000 ms |
| Student action required | None (texture) or one blink | One blink |
| What it closes | Printed photo / screen spoofing | Same, plus adds anti-replay |
| What it does NOT close | Gap 1 (student in corridor, not classroom) | GPS already handles location |
| Combined with | doubleoffline_verif Methods for presence gap | Existing GPS heartbeat |

---

## Recommended Integration Order

**Step 1 — Add OpenCV to the VLAN server with texture analysis.**
This is the safest starting point. It runs on a single frame, requires no student
action, and can be implemented as a Python microservice alongside the existing
server.js without touching any existing code paths. It eliminates the most common
spoofing method (showing a photo of someone else) with minimal complexity.

**Step 2 — Add blink detection for high-stakes sessions.**
Once texture analysis is working and stable, add the multi-frame blink check as
an optional harder mode that can be enabled per session when stricter verification
is needed.

**Step 3 — Extend to online mode.**
The same Python microservice can serve both offline and online requests. Because
online mode already has HTTPS and the server is always-on Linux, the integration
is simpler on the infrastructure side. Add texture analysis first, then blink
detection as online mode already has more processing headroom.

---

## Implementation Decision Table

| Feature / Approach | Recommended? | Reason |
|---|---|---|
| **Texture analysis liveness (single frame)** | ✅ Yes — implement first | Fast (~200 ms), requires no student action, catches the most common spoofing attempts (printed photo, phone screen). Low risk. |
| **Server-side descriptor computation** | ✅ Yes — implement with texture | Removes client-side trust entirely. The server recomputes the descriptor from the raw image, so a student cannot inject a fake descriptor. |
| **Python microservice (Option 1)** | ✅ Yes — preferred integration path | Easy to install and maintain. Runs alongside server.js without modifying Node.js. Stable across OS and Node.js updates. |
| **Blink detection (multi-frame burst)** | ⚠️ Optional — high-stakes sessions only | More secure but adds ~1 s delay and requires the student to perform an action. Disruptive in large classes. Enable only when needed. |
| **Head movement detection** | ⚠️ Optional — rarely needed | Strongest liveness check but the most disruptive. Adds significant friction for 30–40 students. Reserve for exams or graded labs. |
| **Depth inconsistency detection** | ⚠️ Optional — advanced | Effective but requires more complex OpenCV configuration and heavier processing. Not worth the added complexity for standard lecture sessions. |
| **Node.js OpenCV binding (opencv4nodejs)** | ❌ Not recommended | Requires compiling native C++ modules. Fragile across Node.js and OS updates. More complex to maintain than the Python microservice. No clear advantage. |
| **Running OpenCV on the cloud server only** | ❌ Not recommended alone | VLAN sessions must be handled on the VLAN server. If the cloud goes down, VLAN sessions lose liveness detection entirely. Run on both. |
