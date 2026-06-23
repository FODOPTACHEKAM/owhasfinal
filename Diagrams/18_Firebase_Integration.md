# Diagram 18: Firebase Integration Architecture

## Purpose
Show how Firebase services integrate with OWHAS for cloud backend, authentication, storage, and real-time database.

## Type
**Cloud Architecture Diagram / Integration Architecture**

## Firebase Services Used

### 1. Firebase Authentication

**Purpose:** Manage lecturer and student login credentials

```
Component: Firebase Auth
├─ Method: Email/Password
├─ Optional: Google OAuth, Facebook OAuth
│
├─ User Database:
│  ├─ Stores: email, passwordHash, UID, metadata
│  ├─ Features: Auto-verification, password reset
│  ├─ MFA: Optional TOTP or SMS-based
│  └─ Recovery: Email recovery codes
│
└─ Integration:
   ├─ FlutterFlow SDK: Easy integration
   ├─ Client verification: Firebase SDK
   ├─ Token generation: Auto-issued JWT
   ├─ Session management: Auto-handled
   └─ Refresh: Automatic token refresh
```

**Flow:**
```
Lecturer: Login form
  ├─→ Firebase Auth: signInWithEmailPassword()
  ├─→ Auth verifies credentials against stored hash
  ├─→ Success: Generate idToken (1hr) + refreshToken
  ├─← Return tokens to app
  └─ App stores securely
```

### 2. Firebase Firestore (Real-time Database)

**Purpose:** Store and sync session and attendance data to cloud

```
Component: Cloud Firestore
├─ Type: Document-oriented NoSQL
├─ Scalability: Serverless, auto-scaling
├─ Real-time: Bi-directional sync (optional)
│
├─ Collections:
│  ├─ /users/{userID}
│  │  ├─ Field: email, name, role, department
│  │  └─ Indexed: email, role
│  │
│  ├─ /courses/{courseID}
│  │  ├─ Field: courseCode, courseName, lecturerID, semester
│  │  └─ Indexed: lecturerID, semester
│  │
│  ├─ /sessions/{sessionID}
│  │  ├─ Field: courseID, lecturerID, startTime, endTime, status
│  │  ├─ Subcollection: /sessions/{sessionID}/records
│  │  │  ├─ Field: recordID, studentID, timestamp, verified, faceConfidence
│  │  │  ├─ Indexed: studentID, timestamp
│  │  │  └─ Size: Typically 50-200 documents per session
│  │  └─ Indexed: lecturerID, startTime, status
│  │
│  └─ /reports/{reportID}
│     ├─ Field: sessionID, type (pdf/excel), generatedTime, fileURL
│     └─ Indexed: sessionID, generatedTime
│
├─ Indexing:
│  ├─ Automatic: Single field queries
│  ├─ Composite: Multi-field queries (manual setup)
│  └─ Optimization: Index on (lecturerID, startTime) for session queries
│
├─ Real-time Listeners:
│  ├─ Optional: Set up listeners for live updates
│  ├─ Client: Notified of changes instantly
│  ├─ Bandwidth: Only changed documents transmitted
│  └─ Latency: < 100ms typically
│
├─ Storage:
│  ├─ Size limit: 1MB per document (typical < 10KB)
│  ├─ Total: 50GB+ (depends on plan)
│  └─ Cost: Pay per read/write/delete operation
│
└─ Backup:
   ├─ Automatic: Daily snapshots
   ├─ Retention: 7 days (free), 30+ days (with export)
   └─ Manual: Export via Firebase console
```

**Data Structure Example:**
```
/sessions/sess-abc123xyz
{
  "courseID": "CSE101",
  "lecturerID": "lect-123",
  "startTime": Timestamp(2024-01-15 10:00:00),
  "endTime": Timestamp(2024-01-15 11:50:00),
  "status": "ENDED",
  "totalAttendees": 45,
  "recordsReference": "sessions/sess-abc123xyz/records",
  "createdAt": Timestamp(...),
  "updatedAt": Timestamp(...)
}

/sessions/sess-abc123xyz/records/rec-xyz789
{
  "studentID": "std-001",
  "name": "Ali Ahmed",
  "timestamp": Timestamp(2024-01-15 10:02:15),
  "verified": true,
  "faceConfidence": 0.92,
  "verificationMethod": "face",
  "duplicateDetected": false,
  "location": {
    "latitude": 33.8688,
    "longitude": 73.1012,
    "accuracy": 15
  }
}
```

### 3. Firebase Cloud Storage

**Purpose:** Store and retrieve report files (PDF/Excel)

```
Component: Cloud Storage
├─ Type: Object storage (like AWS S3)
├─ Scalability: Unlimited (pay per GB stored/transferred)
├─ CDN: Integrated (files served from edge nodes)
│
├─ Directory Structure:
│  ├─ /reports/
│  │  ├─ {sessionID}.pdf
│  │  ├─ {sessionID}.xlsx
│  │  └─ ...many files...
│  │
│  ├─ /backups/
│  │  ├─ {date}_backup.tar.gz
│  │  └─ ...incremental backups...
│  │
│  └─ /archives/
│     ├─ {year}/{semester}/
│     └─ ...historical data...
│
├─ File Types Stored:
│  ├─ PDF Reports: ~100-500KB each
│  ├─ Excel Reports: ~50-200KB each
│  ├─ Database Backups: ~5-50MB
│  └─ Average per session: ~300KB
│
├─ Access Control:
│  ├─ Firestore rules: Link Firebase Auth to Storage access
│  ├─ Lecturer: Can access only own reports
│  ├─ Student: No direct access (download via server)
│  └─ Admin: Full access
│
├─ Retrieval:
│  ├─ Signed URLs: Temporary download links (1hr expiry)
│  ├─ SDK download: Direct from Firebase app
│  └─ HTTP GET: Public access (optional, with rules)
│
└─ Retention:
   ├─ Policy: Keep 2 years (archival)
   ├─ Cleanup: Auto-delete after 5 years
   └─ Cost: Pay per GB-month stored
```

### 4. Firebase Cloud Functions

**Purpose:** Serverless backend for processing and automation

```
Component: Cloud Functions
├─ Type: Serverless compute (runs on-demand)
├─ Trigger: HTTP, Firestore, Pub/Sub, Schedule
├─ Language: Node.js, Python, Go
│
├─ Deployed Functions:
│  ├─ Function 1: Report Generation
│  │  ├─ Trigger: On session end
│  │  ├─ Task: Generate PDF/Excel from Firestore data
│  │  ├─ Output: Save to Cloud Storage
│  │  └─ Time: 5-15 seconds
│  │
│  ├─ Function 2: Data Sync Validation
│  │  ├─ Trigger: On /sessions document write
│  │  ├─ Task: Validate data integrity
│  │  ├─ Task: Check constraints (max students, etc.)
│  │  └─ Time: < 500ms
│  │
│  ├─ Function 3: Automatic Backup
│  │  ├─ Trigger: Scheduled (daily, 2 AM UTC)
│  │  ├─ Task: Export Firestore to Cloud Storage
│  │  ├─ Task: Compress and encrypt
│  │  └─ Time: 5-30 minutes (size dependent)
│  │
│  └─ Function 4: Cleanup Job
│     ├─ Trigger: Scheduled (weekly, 3 AM UTC)
│     ├─ Task: Delete old sessions (> 2 years)
│     ├─ Task: Archive to long-term storage
│     └─ Time: 10+ minutes
│
├─ Memory: 512MB-4GB (configurable)
├─ Timeout: Up to 9 minutes per invocation
├─ Cost: Pay per invocation + compute time
└─ Monitoring: Built-in Cloud Logging
```

### 5. Firebase Real-time Database (Realtime DB)

**Purpose:** Optional high-frequency real-time sync (alternative to Firestore)

```
[Not used by default - Firestore is primary]

Note: Firestore recommended over Realtime DB for new projects
├─ Reason 1: Better query capabilities
├─ Reason 2: More flexible schema
├─ Reason 3: Better scaling for large datasets
└─ Could be used for: Live dashboard if very high frequency needed
```

### 6. Firebase Remote Config

**Purpose:** Manage configuration settings from cloud

```
Component: Remote Config
├─ Use Cases:
│  ├─ Feature flags: Enable/disable features
│  ├─ Thresholds: Face recognition confidence threshold
│  ├─ Geofence radius: Default values per location
│  ├─ Rate limits: API rate limiting parameters
│  ├─ A/B testing: Test different UI variants
│  └─ Maintenance mode: Temporarily disable features
│
├─ Configuration Example:
│  {
│    "face_confidence_threshold": {
│      "defaultValue": {"numValue": 0.6}
│    },
│    "max_pin_attempts": {
│      "defaultValue": {"numValue": 5}
│    },
│    "geofence_radius": {
│      "defaultValue": {"numValue": 50}
│    }
│  }
│
├─ Update Flow:
│  ├─ Admin updates config in Firebase console
│  ├─ Changes deployed immediately
│  ├─ Clients fetch on startup (with cache)
│  └─ Override server defaults
│
└─ Benefit: Deploy config changes without app update
```

### 7. Firebase Analytics

**Purpose:** Track usage and user behavior

```
Component: Firebase Analytics
├─ Events Tracked:
│  ├─ session_started
│  ├─ session_ended
│  ├─ attendance_registered
│  ├─ duplicate_detected
│  ├─ gps_verification_failed
│  ├─ report_generated
│  ├─ cloud_sync_completed
│  └─ ...custom events...
│
├─ Data Collected:
│  ├─ User ID
│  ├─ Event name
│  ├─ Parameters (session size, location, etc.)
│  ├─ Timestamp
│  └─ Device info
│
├─ Dashboard:
│  ├─ Usage trends
│  ├─ User retention
│  ├─ Feature usage
│  ├─ Performance metrics
│  └─ Error tracking
│
└─ Privacy: GDPR compliant (respects user privacy)
```

## Integration Flow Diagram

```
OWHAS Application
        ↓
    ┌────────────────────────────────────────┐
    │   FIREBASE SERVICES INTEGRATION        │
    └────────────────────────────────────────┘
        ↓      ↓       ↓       ↓      ↓
    Auth  Firestore Storage Functions Analytics
      ↓      ↓       ↓       ↓      ↓
    [Lecturer login]
          ↓
    [JWT Token Generated]
          ↓
    [Session data synced to Firestore]
          ↓
    [Cloud Function: Report generation]
          ↓
    [Report saved to Cloud Storage]
          ↓
    [Download URL provided to lecturer]
          ↓
    [Analytics: Session tracked]
```

## Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Lecturers can only read/write their sessions
    match /sessions/{sessionId} {
      allow read: if request.auth.uid == resource.data.lecturerID;
      allow write: if request.auth.uid == resource.data.lecturerID;
      
      // Nested: Attendance records
      match /records/{recordId} {
        allow read: if request.auth.uid == get(/databases/$(database)/documents/sessions/$(sessionId)).data.lecturerID;
        allow create: if request.auth != null;  // Students can create
      }
    }
  }
}
```

## Sync Workflow

```
Local App (SQLite) ←→ Firebase Firestore ←→ Cloud Storage

Offline Mode:
  ├─ App saves locally only
  └─ No cloud sync
  
Online Mode:
  ├─ App saves to local DB first
  ├─ Immediately syncs to Firebase
  ├─ Cloud Function processes
  ├─ Report generated
  ├─ Stored in Cloud Storage
  └─ Download link provided

Hybrid Mode:
  ├─ App saves to local DB
  ├─ Also syncs to cloud
  ├─ Dual data path
  └─ Redundancy & backup
```

## Advantages of Firebase Integration

```
✓ No server maintenance needed
✓ Automatic scaling
✓ Built-in security
✓ Real-time data sync
✓ Easy SDK integration
✓ Cost-effective for moderate usage
✓ Integrated analytics
✓ Automatic backups
✓ Global CDN for file delivery
✓ GDPR & compliance tools included
```

## Success Criteria
- All Firebase services shown
- Integration flow clear
- Data structures documented
- Security rules specified
- Sync workflow visible
- Cloud Function triggers shown
- Storage structure detailed
- Real-time listener flow demonstrated
- Cost implications noted

## Tools Suitable For
- Draw.io
- Lucidchart
- Firebase documentation diagrams
- Architecture diagrams

## Related Sections in Final_Doc
- Section 8.3: Firebase Integration
- Section 8: API & Integration
- Section 9.2: Cloud Deployment Architecture
