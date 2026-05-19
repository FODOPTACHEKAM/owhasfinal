# Detailed Explanation — The Three Recommended OpenCV Features for OwHAS

---

## Overview

Three components are marked as the recommended starting point for adding OpenCV
to OwHAS. They are designed to work together as a single pipeline: the Python
microservice is the container that runs everything, texture analysis is the
liveness gate that rejects fake faces, and server-side descriptor computation
is the identity gate that confirms the person is who they claim to be. None of
the three is useful without the others.

This document explains each one in depth — what it is, how it works, why it
was chosen over the alternatives, how it fits into the existing OwHAS
registration flow, and what its limitations are.

---

## Part 1 — Texture Analysis Liveness (Single Frame)

### What the problem is

The current face step in OwHAS asks the student to take a selfie. The browser
runs face-api.js on that image and extracts a 128-number descriptor. Nothing in
this process checks whether the image contains a real, living face or a flat
photograph of one. If a student holds a printed photo of their classmate in
front of the camera, or shows a face on another phone screen, the descriptor
is extracted from that fake face just as easily as from a real one. As long as
the descriptor is close enough to the registered one, the system accepts it.
Texture analysis closes this gap.

### What texture analysis is

Every surface, when photographed, has a characteristic texture — a pattern of
tiny variations in colour and brightness at the pixel level. A real human face
has pores, fine hair follicles, natural skin irregularities, subtle colour
gradients caused by blood beneath the skin, and micro-shadows in the contours
of the face. All of these produce a rich, complex texture when captured by a
camera.

A printed photo, even a high-quality one, has a completely different surface
texture. The ink pattern of a laser or inkjet printer is visible at the pixel
level as a regular dot matrix or halftone grid. A face displayed on a phone
screen has the texture of the screen itself — a regular grid of RGB subpixels,
often with a slight moire pattern, and a uniform backlit glow that real skin
does not produce.

Texture analysis reads these micro-patterns and classifies the surface as either
a real face or a flat reproduction. The algorithm used for this is called Local
Binary Pattern Histogram, or LBPH.

### How LBPH works

LBPH works by examining each pixel in the face region and comparing it to its
eight surrounding neighbours. For each pixel, it produces a binary number: for
each neighbour, the number contains a 1 if the neighbour is brighter than the
centre pixel, and a 0 if it is darker. The result is an 8-bit code that
describes the local texture pattern around that pixel.

Once every pixel has been assigned a code, the algorithm divides the face into
a grid of small rectangular regions and, in each region, counts how often each
of the 256 possible codes appears. This count is turned into a histogram — a
frequency chart of texture patterns in that region. All the regional histograms
are concatenated into one long vector that describes the texture of the entire
face.

This vector is the texture fingerprint. A real face produces a fingerprint
with certain statistical properties: high variation, irregular patterns, and
distributions that look nothing like the regular, repeating patterns of a
printed or screened surface. By training on a large set of real faces and fake
faces (photos and screens), the system learns what a genuine face fingerprint
looks like. At registration time it computes the student's fingerprint and
compares it to the learned boundary. If it falls in the real region, the face
passes. If it falls in the fake region, the face is rejected.

### Why a single frame is enough

Texture analysis only needs one photograph because it is analysing a spatial
property — the micro-texture of the skin — rather than a temporal property like
movement. The difference between a real face and a printed one is visible in
any single frame. This is what distinguishes texture analysis from blink
detection, which requires multiple frames over time to observe movement.
The single-frame requirement means there is no video burst to send, no timing
window to manage, and no mobile browser compatibility problem. The student
takes one selfie, exactly as they do today, and the server does the rest.

### What it catches and what it does not

Texture analysis reliably catches the two most common and most accessible
spoofing methods: a printed photo and a face on a phone screen. Both surfaces
have textures that are detectably different from real skin under the LBPH
analysis.

It does not catch a high-definition video of the target person played on a
professional display, because a high-quality screen at close range can
produce skin-like pixel variation. It also does not catch deepfakes, which
generate synthetic images that may not have the telltale printer or screen
texture. These are advanced attacks that require significant effort and
equipment. For the threat level of a university attendance system, texture
analysis covers the realistic risk.

### Where it fits in the OwHAS registration flow

Texture analysis runs inside the `/api/verify-face` endpoint, immediately after
the server receives the raw image from the browser. It is the first check the
image passes through. If texture analysis fails, the server returns an error
and the student must retake their photo. The `faceId` one-time token is never
issued. The student cannot proceed to the details form. If texture analysis
passes, the pipeline continues to descriptor computation and the duplicate
check.

### Speed

The LBPH computation on a single face region takes approximately 50 to 150
milliseconds on a standard server CPU. The total response time for
`/api/verify-face` — including image decoding, face detection, texture analysis,
and descriptor extraction — is typically under 300 milliseconds on the school
VLAN server. From the student's perspective this is imperceptible compared to
the existing face-api.js processing time in the browser.

---

## Part 2 — Server-Side Descriptor Computation

### What the problem is

In the current system, face-api.js runs inside the student's browser. The
browser extracts the 128-dimension face descriptor and sends it to the server.
The server never sees the original photo — it only receives the array of numbers.

This creates a trust problem. The descriptor is computed on hardware and software
that the student fully controls. A student who is determined to cheat could use
browser developer tools, a custom script, or a network proxy to intercept the
request between the browser and the server and replace the descriptor before it
is sent. They could substitute a pre-computed descriptor from a photo of the
person they want to impersonate. The server would receive a valid-looking
128-number array, compare it against stored descriptors, find a match below the
0.45 threshold, and flag it as a proxy attempt — but if the attacker computed
the descriptor from the correct person's photo, there would be no mismatch to
detect at all.

### What server-side computation means

When the server receives the raw image instead of the descriptor, it performs
the descriptor extraction itself using its own copy of the face recognition
model. The student's device never runs the recognition model at all — it simply
sends the photograph. The number the server computes from that photograph cannot
be altered by the student because the computation happens entirely on the server
after the image arrives.

This means the descriptor comparison — checking whether the face in the image
matches any previously registered face in the session — is now performed on
data that the server generated, not data the student provided. The 0.45
Euclidean distance threshold check, the proxy detection, and the faceId token
issuance all operate on a trustworthy input.

### What model the server uses

The server uses OpenCV's deep neural network face recognition module. The
recommended model is `SFace` (also called `FaceRecognizerSF` in OpenCV's API),
which is a lightweight model designed specifically for this purpose. It produces
a 128-dimension descriptor, the same dimensionality as face-api.js, so the
existing 0.45 threshold and the existing duplicate detection logic do not need
to change.

Alternatively, the server can use a FaceNet model loaded through OpenCV's DNN
module. FaceNet is slightly more accurate on difficult images (low light, partial
occlusion) but requires more processing time. For the VLAN scenario, where
registration speed matters, SFace is the more appropriate choice.

### How it connects to texture analysis

Texture analysis and descriptor computation run on the same image, in sequence.
The server first checks whether the face is real (texture analysis). Only if
that passes does it extract the descriptor. This ordering is important: there is
no point computing a descriptor from a fake face, because doing so gives the
attacker information about how close their fake was to the threshold. By
rejecting fake faces before extraction, the server gives less information to
anyone probing the system.

### What changes in the registration flow

The browser no longer needs to load or run face-api.js for the descriptor
computation. It still uses face-api.js for the initial face detection in the
browser — to confirm a face is visible before sending the image, and to produce
the biometric summary displayed to the student (age, gender, expression). But
the descriptor that matters for identity verification is now the one the server
computes, not the one the browser computes. The browser's descriptor is
discarded on the server side.

The image sent from the browser to `/api/verify-face` replaces the descriptor
array in the request body. The response from the server — the `faceId` token —
is the same as before. The student sees no difference. The rest of the flow
(biometric-connect, session commit, dashboard polling) is completely unchanged.

### What this does not protect against

Server-side computation eliminates descriptor injection but does not prevent
a student from sending a manipulated image. An attacker could take a real photo
of the person they want to impersonate and send that image directly to the
server, bypassing the browser entirely, using a script or tool like curl. The
server would compute a genuine descriptor from that photo and it would match if
the photo is of the registered person. This attack requires more technical
knowledge than modifying a descriptor array, but it is still possible. The
mitigation is to combine server-side computation with texture analysis: the
manipulated image, which would typically come from a saved photo, would fail the
texture check before the descriptor is ever extracted.

---

## Part 3 — Python Microservice (Option 1)

### What it is

The Python microservice is a small, independent HTTP server that runs on the
same machine as the Node.js `server.js`. It runs as a separate process on a
different port — a port that is only accessible from the local machine itself,
not from the network. When a student submits a face image, `server.js` receives
the request, forwards the image to the Python microservice over this internal
connection, waits for the result, and continues processing based on what the
Python service returns.

The Python microservice contains all of the OpenCV logic: image decoding, face
detection, texture analysis, descriptor extraction, and the liveness decision.
`server.js` contains none of this logic — it only knows how to ask the Python
service for a result and how to interpret the response.

### Why Python and not Node.js

OpenCV's primary and best-supported language binding is Python. The Python
binding (`cv2`) exposes the full OpenCV API, is updated alongside each OpenCV
release, has comprehensive documentation, and has a large ecosystem of tutorials,
pre-trained models, and supporting libraries. Every liveness detection tutorial,
every face recognition example, and every LBPH or DNN integration guide that
exists online is written for Python.

The Node.js binding for OpenCV (`opencv4nodejs`) is a community-maintained
wrapper around the C++ library. It requires compiling native C++ code during
installation. On different operating systems, different versions of Node.js, or
different versions of the Visual C++ build tools on Windows, this compilation
can fail or produce a broken installation. When the Node.js version is updated
— which happens regularly — the native module must be recompiled. Maintaining
this over the lifetime of a project is a recurring source of problems. The
Python microservice approach avoids all of this.

### Why a separate process and not an embedded script

Python and Node.js cannot run in the same process. Even if they could, mixing
the two runtimes would create a fragile, hard-to-debug system. Keeping them as
separate processes is the standard and well-understood way to combine them. It
also means the Python service can be restarted, updated, or replaced without
touching the Node.js server, and vice versa.

### How the internal communication works

`server.js` and the Python microservice communicate over HTTP on the loopback
interface (localhost). The loopback interface is an internal virtual network
connection that exists only within the machine — no data travels over the actual
VLAN or any external network. When `server.js` needs a face checked, it sends
the image to a specific address and port on localhost. The Python service
processes the image and sends back a JSON result: whether liveness passed,
whether a face was found, the computed descriptor, and a confidence score.
`server.js` reads this result and decides whether to issue the `faceId` token.

Because this communication is on localhost, it is extremely fast — typically
under one millisecond of network overhead. The total round-trip adds essentially
no latency beyond the processing time of the OpenCV pipeline itself.

### Startup and shutdown

Both processes start together. The simplest approach is a single startup script
that launches the Python microservice first and then starts `server.js`. When
`server.js` starts it waits a moment for the Python service to be ready before
accepting student connections. If the Python service crashes or is unavailable,
`server.js` can either reject face verification requests with an appropriate
error message, or fall back to accepting the browser-provided descriptor (the
current behaviour) until the Python service recovers.

### What happens to face-api.js in the browser

face-api.js continues to run in the browser, but its role changes. It is no
longer the source of the descriptor used for identity verification — the server
computes that independently. Instead, face-api.js serves two purposes it always
had but that are now its only role:

First, it confirms that a face is present and visible before the image is
uploaded. If face-api.js cannot detect a face in the browser, the student is
asked to retake the photo before anything is sent to the server. This saves a
server round-trip for obviously bad images.

Second, it produces the biometric summary shown to the student — the estimated
age, gender, and expression — which appears after the face step as confirmation
that the capture was successful. This is a display feature and has no security
role.

### Stability and maintainability

Because the Python microservice is separate from `server.js`, updating OpenCV,
adding a new liveness model, or tuning the descriptor threshold can be done by
modifying the Python code alone. The Node.js server does not change. Conversely,
updating Node.js, adding new server endpoints, or changing session logic in
`server.js` does not affect the Python service. The two components can evolve
independently, which makes the system easier to maintain over time.

---

## How the Three Components Work Together

When a student reaches the face step in `hotspot.html` and submits their selfie,
the following sequence happens:

The browser sends the raw image to `server.js` at the `/api/verify-face`
endpoint, along with the session PIN.

`server.js` receives the image and forwards it to the Python microservice over
the localhost connection.

The Python microservice decodes the image and checks whether a face is present.
If no face is found, it returns an error immediately.

If a face is found, the Python microservice runs texture analysis using LBPH.
If the texture check determines the face is a flat reproduction, it returns a
liveness failure. `server.js` sends the student an error: the system detected a
photo or screen, and they should retake with a real selfie.

If texture analysis passes, the Python microservice extracts the 128-dimension
descriptor using the OpenCV SFace model and returns it to `server.js` along with
a liveness pass result.

`server.js` takes the descriptor it received from the Python service and runs
the existing duplicate check: it computes the Euclidean distance between this
descriptor and every descriptor already stored in the session. If any distance
is below 0.45, the face is already registered and the request is rejected as a
proxy attempt.

If the face is unique, `server.js` stores the descriptor, generates the one-time
`faceId` token, and returns it to the browser. The student proceeds to the
details form as normal. The rest of the registration flow is unchanged.

---

## What These Three Components Together Do and Do Not Provide

| Capability | Provided? |
|---|---|
| Detect a printed photo | ✓ Yes — texture analysis |
| Detect a face on a phone screen | ✓ Yes — texture analysis |
| Prevent descriptor injection by a technical attacker | ✓ Yes — server-side computation |
| Detect the same face registering twice in one session | ✓ Yes — duplicate check with server descriptor |
| Confirm the student is physically in the classroom | ✗ No — see doubleoffline_verif.md |
| Detect a video replay attack | ✗ No — single-frame texture analysis cannot detect video |
| Detect a deepfake image | ✗ No — requires a separate, more complex anti-spoofing model |
| Replace face-api.js in the browser entirely | ✗ No — face-api.js still handles preview, display, and pre-send validation |
