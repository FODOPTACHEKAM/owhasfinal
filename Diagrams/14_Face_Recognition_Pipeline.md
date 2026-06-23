# Diagram 14: Face Recognition Pipeline

## Purpose
Show the detailed process flow of face detection, descriptor extraction, and verification for proxy detection.

## Type
**Process Flow Diagram / Pipeline Architecture**

## Stage 1: Image Input

**Source:** Student's device camera
**Format:** Raw video frame (JPEG/PNG)
**Dimensions:** Typically 640x480 or higher
**Color Space:** RGB

**Processing:**
- Capture single frame from video stream
- Compress to reasonable size (< 1MB)
- Convert to canvas element (for face-api.js)

**Output:** Image data ready for detection

## Stage 2: Face Detection (face-api.js)

### Sub-process: CNN Face Detection
```
Input: Image (RGB)
  ↓
Model 1: Tiny Face Detector (Fast, real-time)
  └─ Detects face bounding boxes
    - Returns: [x, y, width, height] coordinates
    - Confidence scores for each detection
  ↓
Decision: Face(s) found?
  ├─ NO FACE: Return error, ask for retry
  ├─ ONE FACE: Continue to next stage ✓
  └─ MULTIPLE: Return error, ask to be alone
  ↓
Face Bounding Box: Precise face region identified
```

### Sub-process: Face Landmark Detection
```
Input: Face region (from bounding box)
  ↓
Model 2: Face Landmarks (68 points)
  └─ Detects facial features:
    - Eyes (4 points each)
    - Nose (1 point)
    - Mouth (12 points)
    - Jawline (17 points)
    - Eyebrows (10 points)
  ↓
Output: [68 coordinate pairs] = Facial geometry
```

### Sub-process: Face Pose & Angle Check
```
Input: Facial landmarks
  ↓
Calculate:
  - Head yaw (left/right rotation)
  - Head pitch (up/down tilt)
  - Head roll (tilt angle)
  ↓
Validate: Face frontal (within threshold)?
  ├─ YES: Front-facing, good for verification ✓
  └─ NO: Warning "Face too angled, please face camera"
```

### Sub-process: Face Expression Detection (Optional)
```
Input: Face region
  ↓
Model 3: Facial Expressions
  └─ Detects:
    - Neutral, happy, sad, angry, fearful, disgusted, surprised
  ↓
Output: Expression confidence scores (used for liveness check)
  ├─ Shows genuine expression changes? → More trustworthy
  └─ Static/no expression? → May be photo/screenshot
```

## Stage 3: Image Quality Assessment

**Criteria to Evaluate:**

1. **Brightness**
   - Calculate average pixel intensity
   - Check if too dark or too bright
   - Ideal: 100-200 average intensity

2. **Sharpness (Blur Detection)**
   - Apply Laplacian filter
   - Calculate variance
   - High variance = sharp, low = blurry

3. **Face Size**
   - Bounding box area relative to image
   - Too small: < 10% of image (too far)
   - Too large: > 80% of image (too close)
   - Ideal: 20-50% of image

4. **Contrast**
   - Ratio of brightest to darkest regions
   - Low contrast = no facial features visible
   - Needed for landmark detection

5. **Lighting**
   - Extreme shadows on face?
   - Uneven lighting across face?
   - Backlit scenario?

**Quality Score Calculation:**
```
Quality = (Brightness_ok × 0.25 +
           Sharpness_ok × 0.25 +
           FaceSize_ok × 0.25 +
           Contrast_ok × 0.25)
           
Threshold: Quality >= 0.70 (70%)
```

**Decision:**
```
Quality >= Threshold?
  ├─ YES: Proceed to descriptor extraction ✓
  └─ NO: Show warning "Poor image quality"
         Ask to: Better lighting, Adjust position, Retake
```

## Stage 4: Face Recognition (Descriptor Extraction)

### Model 4: Face Recognition (ResNet or MobileNet)
```
Input: Validated face region + landmarks
  ↓
Deep Neural Network Process:
  1. Convert face region to 128x128 RGB input
  2. Pass through 20+ layers of convolution
  3. Apply ReLU activations and pooling
  4. Extract features at various scales
  5. Final fully connected layer outputs vector
  ↓
Output: Face Descriptor = [128 floating point values]
  └─ Each value ranges from -1 to 1
  └─ Represents unique facial characteristics
  └─ Normalized L2 distance
```

### Descriptor Properties
- **Dimensionality:** 128 dimensions
- **Data Type:** Float32 array
- **Normalization:** L2 normalized (unit length)
- **Interpretation:** Black-box deep learning features
- **Uniqueness:** Different for each face (ideally)
- **Consistency:** Same face = similar descriptor (distance < threshold)

**Example Descriptor (first 10 of 128):**
```
[0.234, -0.567, 0.123, -0.890, 0.456, 0.234, -0.123, 0.567, -0.345, 0.789, ...]
```

## Stage 5: Descriptor Comparison & Duplicate Detection

### Sub-process: Database Query
```
Input: New face descriptor
  ↓
Query: "Get all descriptors for this session"
  ├─→ Local Database: SELECT * FROM FaceDescriptors 
      WHERE sessionID = current_session
  └─← Return: List of all captured face descriptors in session
      (if this is 5th student, get 4 previous descriptors)
```

### Sub-process: Distance Calculation
```
For each stored descriptor:
  |
  ├─ Calculate Euclidean Distance:
  |   distance = sqrt(sum((new_desc[i] - stored_desc[i])^2))
  |             for i = 0 to 127
  |
  ├─ Result: Single float value
  |   - Distance 0.0: Identical faces
  |   - Distance 0.5: Similar faces
  |   - Distance 1.0+: Different faces
  |
  └─ Record: {storedDescriptorID, distance, similarity%}
     
Similarity = (1 - distance) × 100%
  ├─ > 60% match: Possible duplicate ⚠️
  └─ < 40% match: Unique face ✓
```

### Sub-process: Duplicate Decision
```
Threshold: 0.6 (configurable)

For each comparison:
  |
  ├─ If distance < 0.6:
  |   └─ DUPLICATE ALERT! 🚨
  |     ├─ Log: Potential proxy attempt
  |     ├─ Alert: Send to lecturer dashboard
  |     ├─ Display: Warning to student
  |     │         "Your face is similar to another person"
  |     │         "Verify with your lecturer"
  |     └─ Action: Flag record, Escalate, Require manual verification
  |
  └─ If distance >= 0.6 for ALL:
      └─ UNIQUE FACE ✓
        ├─ Proceed with registration
        ├─ Store new descriptor
        └─ Mark as verified
```

## Stage 6: Confidence Scoring

**Factors Contributing to Confidence:**

1. **Face Detection Confidence**
   - From face-api.js detection model
   - How certain is the face detected?
   - Score: 0-100%

2. **Quality Score**
   - From image quality assessment
   - Is the image suitable for recognition?
   - Score: 0-100%

3. **Match Confidence** (if comparing to stored)
   - How similar to stored descriptor?
   - 1 - Euclidean_distance
   - Score: 0-100%

4. **Liveness Confidence** (if checking for real face)
   - Does face show genuine expressions?
   - Blink detection?
   - Head movement?
   - Score: 0-100%

**Final Confidence Score:**
```
FinalConfidence = (Detection_conf × 0.25 +
                   Quality_score × 0.25 +
                   Match_conf × 0.25 +
                   Liveness_conf × 0.25)
```

## Stage 7: Storage

### FaceDescriptors Table
```
INSERT INTO FaceDescriptors (
  descriptorID,     // Unique ID
  studentID,        // Student who registered
  sessionID,        // Session for this registration
  descriptor,       // JSON array of 128 floats
  imageURL,         // Optional: stored image
  imageQuality,     // Quality score (0-100)
  faceConfidence,   // Detection confidence
  captureTime       // When captured
)
```

### AttendanceRecords (Links back)
```
UPDATE AttendanceRecords
SET faceDescriptorID = descriptor_id,
    faceConfidence = confidence_score,
    duplicateDetected = false  // or true if duplicate
```

## Stage 8: Real-time Feedback Loop

**During Capture (Continuous):**
```
Video Frame Loop (every 100-200ms):
  |
  ├─ Detect face in current frame
  ├─ Calculate quality
  ├─ Show real-time feedback:
  │  - Green box: "Good" (centered, lit, sharp)
  │  - Yellow box: "Adjust" (angle, brightness)
  │  - Red box: "Too close/far" (size)
  ├─ Update UI: "Position face in frame"
  └─ Wait for user to click "Capture"
```

**After Capture:**
```
Processing Feedback:
  |
  ├─ Show spinner: "Verifying face..."
  ├─ Calculate descriptor (1-2 sec)
  ├─ Compare with existing (< 1 sec)
  ├─ Decision made: "Verified" or "Duplicate"
  └─ Show result to user
```

## Error Handling in Pipeline

```
Potential Errors:
│
├─ NO FACE DETECTED
│  └─ Retry: Ask to position face
│
├─ MULTIPLE FACES
│  └─ Retry: Ask others to leave
│
├─ POOR IMAGE QUALITY
│  └─ Retry: Better lighting/angle
│
├─ FACE TOO SMALL/LARGE
│  └─ Retry: Move closer/farther
│
├─ FACE ANGLE TOO EXTREME
│  └─ Retry: Face camera directly
│
├─ DUPLICATE DETECTED
│  └─ Escalate: Lecturer verification
│
├─ DESCRIPTOR EXTRACTION FAILED
│  └─ Retry: Take another photo
│
└─ DATABASE ERROR
   └─ Error handling & logging
```

## Performance Metrics

| Stage | Time | Notes |
|-------|------|-------|
| Image Capture | Instant | From video stream |
| Face Detection | 100-500ms | Real-time detection |
| Landmark Detection | 100-300ms | Simultaneous with face |
| Expression Detection | 100-200ms | Optional |
| Quality Assessment | 50-100ms | Local calculations |
| Descriptor Extraction | 500-2000ms | Heavy computation |
| Comparison (10 stored) | 100-200ms | Vector math |
| Total Pipeline | 1-3 seconds | From click to result |

## Accuracy Metrics

- **Face Detection Accuracy:** > 99% (under good lighting)
- **Landmark Detection:** > 95%
- **False Positive Rate:** < 1% (duplicate false alarm)
- **False Negative Rate:** < 5% (miss actual duplicate)
- **Liveness Detection:** ~ 98% (if enabled)

## Success Criteria
- All pipeline stages shown sequentially
- Decision points clear (accept/reject/retry)
- Error paths visible
- Processing times indicated
- Input/output formats specified
- Database storage shown
- Real-time feedback indicated
- Confidence scoring visible
- Duplicate detection logic clear

## Tools Suitable For
- Draw.io (process flow)
- Lucidchart
- Miro/Mural
- PlantUML (sequence or activity)

## Related Sections in Final_Doc
- Section 7.3: Face Recognition & Anti-Proxy System
- Section 7: Security & Authentication
