# How the Camera Opens on a Student's Device

## The Core Idea

No image is ever sent to the server.
No HTTPS or special permissions are needed.
All face processing runs **inside the student's browser**, on the student's own device.

---

## Step-by-Step: What Happens When a Student Taps "Take Selfie"

### 1. Student opens the page in their browser
The student connects to the lecturer's Wi-Fi hotspot (or the cloud URL) and browses to the registration page. The page is just an HTML file served by `server.js`.

### 2. Browser downloads the face models (once per page load)
The page loads `face-api.min.js` from the server (`/lib/face-api.min.js`).
Then three AI model files are fetched from `/models/`:

| Model | Purpose |
|---|---|
| `tinyFaceDetector` | Detects whether a face is present in the image |
| `faceLandmark68Net` | Locates 68 facial landmarks (eyes, nose, jaw…) |
| `faceRecognitionNet` | Converts the landmarks into a 128-number vector (the "descriptor") |

These run entirely in JavaScript/WebAssembly inside the student's browser — the lecturer's server is just a file host for them.

### 3. `<input capture="user">` opens the camera
The "Take Selfie" button triggers:
```html
<input type="file" accept="image/*" capture="user">
```

`capture="user"` is the key attribute:

| Device | What happens |
|---|---|
| **Android phone** | Opens the front-facing (selfie) camera app natively |
| **iPhone** | Opens the front-facing camera natively |
| **Laptop / desktop** | `capture` is ignored → a normal file-picker dialog opens instead |

No `getUserMedia()` is used — that would require HTTPS. This approach works on plain HTTP because it relies on the native OS camera, not the browser's camera API.

### 4. Face analysis runs on the student's device
After the student takes the photo, the image never leaves the device.
`face-api.js` processes it locally:

```
Captured image
  → TinyFaceDetector  (is there a face?)
  → FaceLandmark68Net (where are the eyes, nose, jaw?)
  → FaceRecognitionNet (convert to 128 numbers)
  → descriptor = [0.12, -0.34, 0.08, … ] (128 floats)
```

If no face is detected, the user is asked to retake the photo.

### 5. Only the 128 numbers are sent to the server
```
POST /api/verify-face
Body: { descriptor: [128 numbers], pin: "1234" }
```

The server compares this vector against every descriptor already stored for the session using **Euclidean distance**:

```
distance = √( Σ (a[i] - b[i])² )   for i = 0..127
```

- Distance **< 0.6** → same person → **rejected** (proxy/duplicate detected)
- Distance **≥ 0.6** → unique face → server issues a one-time `faceId` token (valid 5 minutes)

### 6. Student fills in their details and submits
```
POST /api/biometric-connect
Body: { username, matricule, email, faceId, sessionPin, … }
```

The server:
1. Validates the `faceId` token (must exist, not expired, not already used)
2. Re-checks uniqueness one more time (race-condition guard for simultaneous submissions)
3. Permanently stores the descriptor + student info in the session
4. Returns a `heartbeatToken` if it is an online session (for GPS presence checks)

---

## On a Laptop / Desktop Computer

`capture="user"` is silently ignored by desktop browsers (Chrome, Firefox, Edge).
The file-picker opens instead — the student can select **any image file** from disk.

`face-api.js` then runs on that image exactly the same way.
If the selected image contains a face, detection succeeds normally.
If not (e.g. a logo or landscape photo), the student is asked to pick a different file.

This means desktop students need a photo with a clearly visible face.
The anti-proxy protection still applies — the same face cannot be submitted twice.

---

## Why No Image Reaches the Server

| What is sent | What stays on the device |
|---|---|
| 128 floating-point numbers | The actual photo |
| Student name, ID, email | Raw camera frames |
| GPS coordinates (heartbeat) | Face model weights (after first load, cached by browser) |

This design has two benefits:
1. **Privacy** — the photo is never stored anywhere.
2. **HTTP compatibility** — `getUserMedia` (live webcam API) requires HTTPS; `<input capture>` does not.

---

## Where the Models Come From

The lecturer runs `node setup.js` once on their PC.
`setup.js` downloads the face-api model files into `backend/public/models/`.
From that point, every student who opens the page gets the models served from the lecturer's machine over the local hotspot — no internet needed during class.

On the cloud deployment (`owhas.org`), the models are permanently hosted on the server.
