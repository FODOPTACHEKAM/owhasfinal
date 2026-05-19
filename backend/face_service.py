"""
OwHAS Face Liveness Service
Runs alongside server.js on localhost:5600.
Receives a base64 JPEG image, detects whether the face is a real
live person or a flat reproduction (printed photo / screen display),
and returns a JSON verdict.

Start this service before starting server.js:
    python face_service.py

Required packages:
    pip install -r requirements.txt
"""

from flask import Flask, request, jsonify
import cv2
import numpy as np
import base64
import os

app = Flask(__name__)

# ── Haar cascade for face detection (bundled with every OpenCV install) ──
CASCADE_PATH = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
face_cascade = cv2.CascadeClassifier(CASCADE_PATH)

# ── Liveness thresholds ────────────────────────────────────────────────────
# Laplacian variance: measures how much fine-grained texture exists in the face
# region. A real face captured live has visible pores, micro-shadows, and hair
# follicles that produce high variance. A printed photo or phone screen produces
# smooth, low-variance texture. Empirically calibrated for indoor classroom lighting.
LAPLACIAN_THRESHOLD = 60.0

# Contrast threshold: standard deviation of pixel values in the face region.
# Flat reproductions often have a compressed tonal range.
CONTRAST_THRESHOLD = 12.0

# Minimum face size in pixels. Faces too small to analyse reliably are rejected.
MIN_FACE_PX = 60

# ── Image decoding ────────────────────────────────────────────────────────

def decode_image(b64_string):
    """Decode a base64 data-URI or raw base64 string to a numpy array (BGR)."""
    if ',' in b64_string:
        b64_string = b64_string.split(',', 1)[1]
    img_bytes = base64.b64decode(b64_string)
    arr = np.frombuffer(img_bytes, np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    return img

# ── Liveness analysis ─────────────────────────────────────────────────────

def check_liveness(img):
    """
    Returns (is_live: bool, reason: str).
    is_live  True  — face appears to be a real person.
    is_live  False — possible flat reproduction or quality problem.
    """
    if img is None:
        return False, "Could not decode the image."

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Step 1: Detect faces
    faces = face_cascade.detectMultiScale(
        gray,
        scaleFactor=1.1,
        minNeighbors=5,
        minSize=(MIN_FACE_PX, MIN_FACE_PX),
        flags=cv2.CASCADE_SCALE_IMAGE,
    )

    if len(faces) == 0:
        return False, "No face detected — face the camera directly in good light."

    if len(faces) > 1:
        return False, "Multiple faces detected — only one student per photo."

    x, y, w, h = faces[0]

    if w < MIN_FACE_PX or h < MIN_FACE_PX:
        return False, "Face too small — move closer to the camera."

    # Extract the face region for texture analysis
    face_region = gray[y:y + h, x:x + w]

    # Step 2: Blur / flatness check via Laplacian variance.
    # A printed photo or phone screen has very smooth pixel transitions —
    # the Laplacian (which measures second-order spatial derivatives) returns
    # low variance on flat surfaces and high variance on complex textures.
    lap_var = cv2.Laplacian(face_region, cv2.CV_64F).var()
    if lap_var < LAPLACIAN_THRESHOLD:
        return (
            False,
            f"Image appears too flat or blurry (texture score {lap_var:.1f}). "
            "Use a live selfie — do not photograph a printed photo or screen."
        )

    # Step 3: Contrast check.
    # Printer ink and LCD screens often clip the tonal range, producing unusually
    # low standard deviation across the face region.
    contrast = float(np.std(face_region))
    if contrast < CONTRAST_THRESHOLD:
        return (
            False,
            f"Image contrast too low (score {contrast:.1f}). "
            "Ensure adequate lighting and avoid extreme backlight."
        )

    return (
        True,
        f"Live face confirmed (texture={lap_var:.0f}, contrast={contrast:.0f})."
    )

# ── Endpoints ─────────────────────────────────────────────────────────────

@app.route('/verify', methods=['POST'])
def verify():
    data = request.get_json(silent=True)
    if not data or 'image' not in data:
        return jsonify({'liveness': False, 'reason': 'No image provided.'}), 400

    try:
        img = decode_image(data['image'])
        is_live, reason = check_liveness(img)
        return jsonify({'liveness': is_live, 'reason': reason})
    except Exception as exc:
        return jsonify({'liveness': False, 'reason': f'Processing error: {exc}'}), 500


@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'opencv': cv2.__version__})


# ── Entry point ───────────────────────────────────────────────────────────

if __name__ == '__main__':
    if not os.path.exists(CASCADE_PATH):
        print('[FACE-SERVICE] ERROR: Haar cascade not found at', CASCADE_PATH)
    else:
        print('[FACE-SERVICE] Haar cascade loaded.')
    print('[FACE-SERVICE] OpenCV version:', cv2.__version__)
    print('[FACE-SERVICE] Listening on http://127.0.0.1:5600')
    print('[FACE-SERVICE] Start server.js after this service is running.')
    app.run(host='127.0.0.1', port=5600, debug=False, threaded=True)
