# Diagram 16: API Architecture & Endpoints

## Purpose
Show all API endpoints, request methods, parameters, and responses for the OWHAS backend.

## Type
**API Architecture Diagram with Endpoint Reference**

## REST API Endpoints Structure

### Base URLs
```
Offline Mode: http://localhost:8080
Online Mode: https://owhas.org/api
Institutional: https://atd.ictu.loc:443
```

### Endpoint Categories

## Category 1: Session Management Endpoints

```
POST /api/session/start
├─ Purpose: Initiate new attendance session
├─ Auth: Lecturer token required
├─ Request:
│  {
│    "courseID": "CSE101-S1",
│    "PIN": "1234",
│    "duration": 120,        // minutes
│    "maxStudents": 100,
│    "geofenceLatitude": 33.8688,
│    "geofenceLongitude": 73.1012,
│    "geofenceRadius": 50     // meters
│  }
├─ Response (200):
│  {
│    "sessionID": "sess-abc123xyz",
│    "QR": "data:image/png;base64,...",
│    "PIN": "1234",
│    "startTime": "2024-01-15T10:00:00Z",
│    "status": "ACTIVE"
│  }
└─ Error (400, 401, 500): Error message

POST /api/session/end
├─ Purpose: Close attendance session
├─ Auth: Lecturer token required
├─ Request:
│  {
│    "sessionID": "sess-abc123xyz"
│  }
├─ Response (200):
│  {
│    "sessionID": "sess-abc123xyz",
│    "status": "ENDED",
│    "endTime": "2024-01-15T11:50:00Z",
│    "totalAttendees": 45,
│    "verified": 43,
│    "pending": 2
│  }
└─ Error: Error details

GET /api/session/{sessionID}
├─ Purpose: Retrieve session details and current attendees
├─ Auth: Lecturer or Student (if in session)
├─ Request: No body (sessionID in URL)
├─ Response (200):
│  {
│    "sessionID": "sess-abc123xyz",
│    "courseID": "CSE101",
│    "courseName": "Introduction to Programming",
│    "lecturerID": "lect-123",
│    "lecturerName": "Dr. Ahmed Khan",
│    "startTime": "2024-01-15T10:00:00Z",
│    "status": "ACTIVE",
│    "attendees": [
│      {
│        "studentID": "std-001",
│        "name": "Ali Ahmed",
│        "registrationTime": "2024-01-15T10:02:15Z",
│        "verified": true,
│        "faceConfidence": 0.92
│      }
│    ]
│  }
└─ Error: Not found, Unauthorized

GET /api/session/{sessionID}/live
├─ Purpose: Real-time dashboard data (WebSocket)
├─ Auth: Lecturer token
├─ Protocol: WebSocket upgrade
├─ Response (stream):
│  Every update:
│  {
│    "event": "new_attendee",
│    "data": {...},
│    "timestamp": "2024-01-15T10:15:30Z"
│  }
└─ Events: new_attendee, duplicate_detected, student_removed, session_ended
```

## Category 2: Attendance Registration Endpoints

```
POST /api/attendance/verify-pin
├─ Purpose: Validate PIN for session access
├─ Auth: Public (no auth required yet)
├─ Request:
│  {
│    "PIN": "1234",
│    "deviceID": "fingerprint123"
│  }
├─ Response (200):
│  {
│    "valid": true,
│    "sessionToken": "eyJhbcJhGciOiJIUzI1NiI...",
│    "sessionID": "sess-abc123xyz",
│    "sessionInfo": {
│      "courseName": "CSE101",
│      "lecturerName": "Dr. Ahmed",
│      "duration": 120
│    }
│  }
├─ Error (400): { "valid": false, "reason": "Invalid PIN" }
└─ Error (429): Too many failed attempts (rate limit)

POST /api/attendance/verify-face
├─ Purpose: Verify face and check for duplicates
├─ Auth: Session token
├─ Request:
│  {
│    "sessionToken": "eyJhbc...",
│    "faceDescriptor": [0.234, -0.567, ...],  // 128 values
│    "imageData": "base64encodedImage",
│    "deviceID": "fingerprint123"
│  }
├─ Response (200):
│  {
│    "verified": true,
│    "confidence": 0.95,
│    "duplicateDetected": false
│  }
├─ Response (200 - Duplicate):
│  {
│    "verified": false,
│    "duplicateDetected": true,
│    "reason": "Face matches existing attendee",
│    "suggestion": "Verify with lecturer"
│  }
└─ Error (400): Invalid face descriptor

POST /api/attendance/register
├─ Purpose: Final registration submission
├─ Auth: Session token
├─ Request:
│  {
│    "sessionToken": "eyJhbc...",
│    "deviceID": "fingerprint123",
│    "registrationData": {
│      "faceDescriptor": [...],
│      "location": {"latitude": 33.8688, "longitude": 73.1012, "accuracy": 15},
│      "signature": "base64signatureImage",
│      "verificationMethod": "face",
│      "timestamp": "2024-01-15T10:02:15Z"
│    }
│  }
├─ Response (201):
│  {
│    "recordID": "rec-xyz789",
│    "success": true,
│    "message": "Attendance registered successfully",
│    "timestamp": "2024-01-15T10:02:15Z",
│    "studentInfo": {
│      "studentID": "std-001",
│      "name": "Ali Ahmed",
│      "registrationNumber": "2021-001"
│    }
│  }
├─ Error (400): Validation error
├─ Error (409): Student already registered in this session
└─ Error (500): Server error

GET /api/attendance/{sessionID}
├─ Purpose: Get all attendance records for a session
├─ Auth: Lecturer token
├─ Response (200):
│  {
│    "sessionID": "sess-abc123xyz",
│    "records": [
│      {...record 1...},
│      {...record 2...}
│    ],
│    "totalCount": 45,
│    "verifiedCount": 43
│  }
└─ Error: Unauthorized, Not found

DELETE /api/attendance/{recordID}
├─ Purpose: Remove student from session
├─ Auth: Lecturer token
├─ Response (204): No content (success)
└─ Error: Not found, Unauthorized
```

## Category 3: Report Generation Endpoints

```
POST /api/report/generate
├─ Purpose: Generate PDF and Excel reports
├─ Auth: Lecturer token
├─ Request:
│  {
│    "sessionID": "sess-abc123xyz",
│    "formats": ["pdf", "excel"]
│  }
├─ Response (200):
│  {
│    "pdfPath": "/reports/sess-abc123xyz.pdf",
│    "excelPath": "/reports/sess-abc123xyz.xlsx",
│    "fileSize": {"pdf": 245000, "excel": 89000},
│    "generatedTime": "2024-01-15T12:00:00Z"
│  }
└─ Error: Session not found, Empty session

GET /api/report/{sessionID}.pdf
├─ Purpose: Download PDF report
├─ Auth: Lecturer token
├─ Response: PDF file (application/pdf)
└─ Error: Not found

GET /api/report/{sessionID}.xlsx
├─ Purpose: Download Excel report
├─ Auth: Lecturer token
├─ Response: Excel file (application/vnd.openxmlformats-officedocument.spreadsheetml.sheet)
└─ Error: Not found
```

## Category 4: Cloud Synchronization Endpoints

```
POST /api/cloud/sync
├─ Purpose: Sync session data to Firebase
├─ Auth: Firebase ID token + Lecturer token
├─ Request:
│  {
│    "sessionID": "sess-abc123xyz",
│    "authToken": "firebaseIdToken...",
│    "includeReports": true
│  }
├─ Response (200):
│  {
│    "success": true,
│    "message": "Data synced to cloud",
│    "cloudURL": "https://firestore.googleapis.com/...",
│    "syncTime": "2024-01-15T12:05:00Z"
│  }
├─ Error (401): Unauthorized - Firebase token invalid
├─ Error (500): Cloud service unavailable
└─ Error (503): Cloud quota exceeded

GET /api/cloud/sessions
├─ Purpose: Retrieve all cloud-synced sessions
├─ Auth: Firebase ID token
├─ Response (200):
│  {
│    "sessions": [
│      {
│        "sessionID": "sess-abc123xyz",
│        "courseName": "CSE101",
│        "syncTime": "2024-01-15T12:05:00Z",
│        "recordCount": 45
│      }
│    ]
│  }
└─ Error: Unauthorized
```

## Category 5: Course Management Endpoints

```
POST /api/courses
├─ Purpose: Create new course
├─ Auth: Lecturer token
├─ Request:
│  {
│    "courseCode": "CSE101",
│    "courseName": "Introduction to Programming",
│    "semester": 1,
│    "creditHours": 3
│  }
├─ Response (201): Course created
└─ Error: Already exists, Invalid data

GET /api/courses
├─ Purpose: Get lecturer's courses
├─ Auth: Lecturer token
├─ Response (200):
│  {
│    "courses": [
│      {...course 1...},
│      {...course 2...}
│    ]
│  }
└─ Error: None

PUT /api/courses/{courseID}
├─ Purpose: Update course
├─ Auth: Lecturer token
├─ Response (200): Updated
└─ Error: Not found, Unauthorized
```

## Category 6: User Management Endpoints

```
POST /api/auth/login
├─ Purpose: Lecturer login (Firebase)
├─ Auth: Public
├─ Request:
│  {
│    "email": "lecturer@university.edu",
│    "password": "SecurePassword123"
│  }
├─ Response (200):
│  {
│    "idToken": "eyJhbcJhGciOiJIUzI1NiI...",
│    "refreshToken": "AEwA0hY...",
│    "expiresIn": 3600,
│    "userID": "user123"
│  }
└─ Error (401): Invalid credentials

POST /api/auth/logout
├─ Purpose: Logout
├─ Auth: Any token
├─ Response (200): Logged out
└─ Error: None

POST /api/auth/refresh
├─ Purpose: Refresh expired token
├─ Auth: Public
├─ Request:
│  {
│    "refreshToken": "AEwA0hY..."
│  }
├─ Response (200):
│  {
│    "idToken": "newToken...",
│    "expiresIn": 3600
│  }
└─ Error (401): Invalid refresh token
```

## Error Response Format (Standard)

```json
{
  "error": {
    "code": "INVALID_PIN",
    "message": "The PIN you entered is incorrect",
    "details": {
      "attempts": 2,
      "maxAttempts": 5,
      "fieldName": "PIN"
    },
    "timestamp": "2024-01-15T10:02:15Z"
  }
}
```

## HTTP Status Codes Used

| Code | Meaning | Example |
|------|---------|---------|
| 200 | OK | Request successful |
| 201 | Created | New record created |
| 204 | No Content | Deletion successful |
| 400 | Bad Request | Invalid PIN format |
| 401 | Unauthorized | Invalid token |
| 403 | Forbidden | No permission |
| 404 | Not Found | Session not found |
| 409 | Conflict | Student already registered |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Server Error | Database error |
| 503 | Service Unavailable | Cloud offline |

## Rate Limiting

```
PIN Verification: 5 attempts per minute per IP
Registration: 1 per student per session
Report Download: 10 per hour per user
All endpoints: 100 requests per minute per IP
```

## Authentication Header Format

```
Authorization: Bearer eyJhbcJhGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## CORS Policy

```
Allowed Origins:
  - http://localhost:8080 (local dev)
  - https://owhas.org (cloud)
  - https://atd.ictu.loc (institutional)
  - https://*.ictu.loc (institutional subdomains)

Allowed Methods:
  - GET, POST, PUT, DELETE, OPTIONS

Allowed Headers:
  - Content-Type
  - Authorization
  - X-Requested-With
```

## API Documentation Location
```
Swagger/OpenAPI: https://owhas.org/api/docs
Postman Collection: [link to collection]
```

## Success Criteria
- All major endpoints shown
- Request/response formats documented
- Error codes and messages specified
- Authentication requirements clear
- Rate limiting indicated
- Status codes comprehensive
- Example payloads provided
- Base URLs clear

## Tools Suitable For
- Draw.io (diagram)
- Lucidchart
- Swagger/OpenAPI (interactive)
- Postman (testing)
- Stoplight (API design)

## Related Sections in Final_Doc
- Section 8.1: Backend API Endpoints
- Section 8: API & Integration
