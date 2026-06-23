# Diagram 17: Data Message Flow

## Purpose
Show how data messages flow between different system components and the format/structure of messages.

## Type
**Data Flow Diagram / Message Sequence**

## Message Flow Paths

### Path 1: PIN Verification Message Flow

```
BROWSER → SERVER (Request)
═══════════════════════════
Format: HTTP POST JSON
URL: http://localhost:8080/api/attendance/verify-pin
Content-Type: application/json

Message:
{
  "PIN": "1234",
  "deviceID": "f4a56c8d9e2b1a7c",
  "timestamp": "2024-01-15T10:02:00Z"
}

Size: ~100 bytes
Encryption: HTTPS/TLS


SERVER → BROWSER (Response)
═══════════════════════════
Status: 200 OK
Content-Type: application/json

Message:
{
  "valid": true,
  "sessionToken": "eyJhbcJhGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "sessionID": "sess-abc123xyz",
  "sessionInfo": {
    "courseName": "CSE101",
    "lecturerName": "Dr. Ahmed",
    "duration": 120,
    "geofenceLatitude": 33.8688,
    "geofenceLongitude": 73.1012
  }
}

Size: ~400 bytes
Time to transmit: < 100ms (typical)
```

### Path 2: Face Registration Message Flow

```
BROWSER → SERVER (Face Registration Request)
═════════════════════════════════════════════
Format: HTTP POST Multipart/JSON
URL: http://localhost:8080/api/attendance/register
Content-Type: application/json

Message Structure:
{
  "sessionToken": "eyJhbc...",
  "deviceID": "f4a56c8d9e2b1a7c",
  "registrationData": {
    "faceDescriptor": [
      0.234, -0.567, 0.891, ..., 0.123  // 128 float values
    ],
    "imageData": "data:image/png;base64,iVBORw0KGgo...",
    "location": {
      "latitude": 33.8688,
      "longitude": 73.1012,
      "accuracy": 15
    },
    "signature": "data:image/png;base64,SGVsbG8gd29ybGQ...",
    "timestamp": "2024-01-15T10:02:15Z"
  }
}

Components:
  ├─ Face descriptor: 128 × 4 bytes = 512 bytes
  ├─ Image (base64): ~50KB compressed
  ├─ Signature (base64): ~10KB compressed
  └─ JSON overhead: ~2KB

Total Size: ~62KB
Compression: gzip recommended
Encryption: HTTPS/TLS
Transmission Time: 200-500ms (depends on network)


SERVER → BROWSER (Registration Success Response)
════════════════════════════════════════════════
Status: 201 Created
Content-Type: application/json

Message:
{
  "recordID": "rec-xyz789",
  "success": true,
  "message": "Attendance registered successfully",
  "timestamp": "2024-01-15T10:02:15Z",
  "studentInfo": {
    "studentID": "std-001",
    "name": "Ali Ahmed",
    "registrationNumber": "2021-001"
  }
}

Size: ~300 bytes
Transmission Time: < 100ms
```

### Path 3: Live Dashboard Update (WebSocket)

```
SERVER ←→ FLUTTER APP (WebSocket Connection)
════════════════════════════════════════════
Protocol: WebSocket (upgrades from HTTP)
URL: ws://localhost:8080/api/session/{sessionID}/live
Connection: Persistent (stays open during session)

Initial Connection:
{
  "event": "connected",
  "sessionID": "sess-abc123xyz",
  "serverTime": "2024-01-15T10:00:00Z"
}

Real-time Updates (sent as events occur):

Event 1: New Student Registered
─────────────────────────────────
{
  "event": "new_attendee",
  "data": {
    "recordID": "rec-xyz789",
    "studentID": "std-001",
    "name": "Ali Ahmed",
    "registrationTime": "2024-01-15T10:02:15Z",
    "verificationMethod": "face",
    "faceConfidence": 0.92,
    "duplicateDetected": false
  },
  "timestamp": "2024-01-15T10:02:15Z"
}

Size: ~300 bytes
Latency: < 100ms (real-time)

Event 2: Duplicate Face Detected!
──────────────────────────────────
{
  "event": "duplicate_detected",
  "data": {
    "recordID": "rec-xyz790",
    "studentName": "Ali Ahmed",
    "registrationTime": "2024-01-15T10:05:00Z",
    "matchPercentage": 0.85,
    "matchedWith": "rec-xyz789",
    "alert": true,
    "requiresManualApproval": true
  },
  "timestamp": "2024-01-15T10:05:00Z"
}

Size: ~250 bytes
Priority: HIGH (alerts lecturer immediately)

Event 3: Dashboard Stats Update
───────────────────────────────
Sent periodically (every 5-10 seconds):
{
  "event": "stats_update",
  "data": {
    "totalAttendees": 45,
    "verifiedAttendees": 43,
    "pendingAttendees": 0,
    "duplicatesDetected": 2,
    "averageRegistrationTime": 8.5  // seconds
  },
  "timestamp": "2024-01-15T10:15:30Z"
}

Size: ~150 bytes
Frequency: Every 5-10 seconds
```

### Path 4: Cloud Synchronization Message Flow

```
FLUTTER APP → FIREBASE (Cloud Sync Request)
═════════════════════════════════════════════
Protocol: HTTPS REST (Firebase REST API)
URL: https://firestore.googleapis.com/v1/projects/{project}/databases/...
Headers:
  Authorization: Bearer {idToken}
  Content-Type: application/json

Message Batch (multiple records in one request):
[
  {
    "fields": {
      "sessionID": {"stringValue": "sess-abc123xyz"},
      "courseName": {"stringValue": "CSE101"},
      "lecturerID": {"stringValue": "lect-123"},
      "startTime": {"timestampValue": "2024-01-15T10:00:00Z"},
      "attendees": {
        "arrayValue": {
          "values": [
            {"mapValue": {"fields": {...attendee1...}}},
            {"mapValue": {"fields": {...attendee2...}}}
          ]
        }
      }
    }
  }
]

Size: ~30-50KB per sync (compressed)
Encryption: TLS 1.2+
Transmission Time: 1-5 seconds (depends on network)


FIREBASE → FLUTTER APP (Sync Confirmation)
═══════════════════════════════════════════
Status: 200 OK
Content-Type: application/json

Message:
{
  "document": {
    "name": "projects/owhas-proj/databases/...",
    "fields": {...sync response...},
    "createTime": "2024-01-15T12:05:00Z",
    "updateTime": "2024-01-15T12:05:00Z"
  }
}

Indicates: Successfully written to Firestore
```

### Path 5: Database Write Message Flow

```
SERVER → LOCAL DATABASE (Query/Write Operations)
═════════════════════════════════════════════════
Protocol: Direct File I/O or SQL over local socket
Database: SQLite / JSON file

Query Type 1: INSERT New Attendance Record
─────────────────────────────────────────
SQL:
INSERT INTO AttendanceRecords (
  recordID, sessionID, studentID, deviceID,
  registrationTime, verificationMethod,
  faceConfidence, location, duplicateDetected
) VALUES (
  'rec-xyz789', 'sess-abc123xyz', 'std-001',
  'f4a56c8d9e2b1a7c', '2024-01-15T10:02:15Z',
  'face', 0.92, '{"lat":33.8688,"lon":73.1012}', false
);

Execution Time: < 50ms
Record Size: ~500 bytes
Transaction: ACID (atomic)

Query Type 2: SELECT Session Statistics
────────────────────────────────────────
SQL:
SELECT COUNT(*) as total, 
       SUM(CASE WHEN duplicateDetected = true THEN 1 ELSE 0 END) as duplicates
FROM AttendanceRecords
WHERE sessionID = 'sess-abc123xyz';

Result:
{
  "total": 45,
  "duplicates": 2
}

Execution Time: < 10ms
Cached: Yes (frequent query)
```

### Path 6: Error Message Flow

```
ERROR Scenario: Invalid PIN
════════════════════════════

BROWSER → SERVER (Request with wrong PIN)
{
  "PIN": "0000",  // Wrong PIN
  "deviceID": "f4a56c8d9e2b1a7c"
}

SERVER → BROWSER (Error Response)
Status: 400 Bad Request
{
  "error": {
    "code": "INVALID_PIN",
    "message": "The PIN you entered is incorrect",
    "details": {
      "attempts": 1,
      "maxAttempts": 5,
      "attempsRemaining": 4
    },
    "timestamp": "2024-01-15T10:02:00Z"
  }
}

Size: ~200 bytes
HTTP Status: 400
Suggested Action: Retry with correct PIN
```

## Data Message Sizes Summary

| Message Type | Size | Latency | Priority |
|--------------|------|---------|----------|
| PIN Verify Request | 100B | <50ms | Normal |
| PIN Verify Response | 400B | <50ms | Normal |
| Face Register Request | 60KB | 200-500ms | High |
| Face Register Response | 300B | <100ms | High |
| WebSocket Event | 150-300B | <100ms | Variable |
| Cloud Sync Batch | 30-50KB | 1-5s | Normal |
| Database Query | 50-500B | <50ms | Normal |
| Error Message | 200B | <50ms | Variable |

## Message Compression

```
Compression Strategy:

1. Large Messages (>1KB)
   └─ Enable gzip compression
   └─ Server: Content-Encoding: gzip
   └─ Browser: Automatic decompression
   └─ Compression Ratio: ~60-70% (good for JSON+images)

2. Image Data
   └─ Pre-compress before base64 encoding
   └─ Format: PNG (lossless, ~50% size)
   └─ Resolution: 800x600 (balance quality vs size)

3. Real-time Events
   └─ No compression (latency critical)
   └─ Small size already (~150-300B)

4. Database Queries
   └─ In-memory compression (SQLite compression)
   └─ Trade-off: CPU vs Storage
```

## Network Resilience

```
Retry Strategy:
─────────────
1. Failed Request: Automatic retry with exponential backoff
   ├─ First retry: After 1 second
   ├─ Second retry: After 2 seconds
   ├─ Third retry: After 4 seconds
   ├─ Max retries: 3
   └─ Total time: Up to 7 seconds before failure

2. WebSocket Disconnection
   ├─ Auto-reconnect: Enabled
   ├─ Interval: 5 seconds with backoff
   ├─ Max retries: Unlimited (with exponential backoff cap)
   └─ User notification: "Reconnecting..."

3. Network Change (WiFi to 4G)
   ├─ Automatic detection
   ├─ Session preservation
   ├─ Seamless fallover (if online mode)
   └─ Retry pending requests
```

## Security for Data in Transit

```
Encryption:

All Messages:
  ├─ HTTPS/TLS 1.2 or higher
  ├─ Certificate pinning (optional, for critical data)
  ├─ Perfect forward secrecy (PFS)
  └─ Cipher: TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (or similar)

Sensitive Data:
  ├─ PIN: Encrypted client-side before transmission
  ├─ Face Descriptors: Encrypted in transit
  ├─ Tokens: Included in Authorization header (HTTPS)
  └─ Signatures: Base64 + encrypted
```

## Message Logging & Monitoring

```
Logged Messages:
─────────────

1. Request Logging
   ├─ Timestamp, Method, URL
   ├─ Request size, Response size
   ├─ Status code, Response time
   ├─ User ID (if authenticated)
   └─ IP address, User-Agent

2. Error Logging
   ├─ Full stack trace
   ├─ Request/Response bodies (sanitized)
   ├─ Database state at time of error
   └─ Retry attempt count

3. Real-time Monitoring
   ├─ Message count per second
   ├─ Average latency
   ├─ Error rate
   ├─ WebSocket connection count
   └─ Alerts on anomalies
```

## Success Criteria
- All major message flows shown
- Request/response formats clear
- Message sizes documented
- Compression strategy shown
- Error handling visible
- WebSocket real-time flow demonstrated
- Network resilience mechanisms shown
- Security encryption indicated
- Logging and monitoring noted

## Tools Suitable For
- Draw.io (flow diagram)
- Lucidchart
- Sequence diagrams
- Wireshark (network capture)
- API documentation tools

## Related Sections in Final_Doc
- Section 8.2: Data Exchange Format
- Section 8: API & Integration
