# Figure 4.15: Firebase Integration Architecture

## Purpose
Shows the cloud architecture and how the Flutter application integrates with Firebase services.

## Diagram Type
**Integration Architecture Diagram**

## Firebase Services Used

### 1. Firebase Authentication
- **Purpose:** User login and identity management for lecturers
- **Auth Method:** Email/Password authentication
- **Features Used:**
  - createUserWithEmailAndPassword()
  - signInWithEmailAndPassword()
  - signOut()
  - currentUser (session persistence)
  - Auth state listener (auto-login)
- **Data Flow:**
  - Flutter App → Firebase Auth: Login credentials
  - Firebase Auth → Flutter App: User token (JWT)

### 2. Cloud Firestore (Database)
- **Purpose:** Cloud document database for sessions and attendance records
- **Collection Structure:**
  ```
  firestore/
  ├── users/
  │   └── {userId}/
  │       ├── name: String
  │       ├── email: String
  │       └── createdAt: Timestamp
  ├── sessions/
  │   └── {sessionId}/
  │       ├── courseName: String
  │       ├── courseCode: String
  │       ├── pin: String
  │       ├── startTime: Timestamp
  │       ├── endTime: Timestamp
  │       ├── status: String
  │       ├── lecturerId: String
  │       └── attendees/
  │           └── {recordId}/
  │               ├── studentName: String
  │               ├── matricNumber: String
  │               ├── timestamp: Timestamp
  │               ├── faceVerified: Boolean
  │               └── deviceFingerprint: String
  └── courses/
      └── {courseId}/
          ├── name: String
          ├── code: String
          └── lecturerId: String
  ```
- **Data Flow:**
  - Flutter App → Firestore: Write session/attendance data
  - Firestore → Flutter App: Read session history, real-time listeners

### 3. Firebase Storage
- **Purpose:** File storage for exported reports and face images
- **Storage Structure:**
  ```
  storage/
  ├── reports/
  │   └── {userId}/
  │       └── {sessionId}/
  │           ├── attendance_report.pdf
  │           └── attendance_report.xlsx
  └── faces/
      └── {sessionId}/
          └── {recordId}.jpg
  ```
- **Data Flow:**
  - Flutter App → Storage: Upload PDF/Excel/images
  - Storage → Flutter App: Download file URLs

### 4. Flutter Application (Client)
- **Firebase SDK:** firebase_core, firebase_auth, cloud_firestore, firebase_storage
- **Initialization:**
  ```dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ```
- **Connection Pattern:**
  - Online: Direct Firebase SDK calls
  - Offline: Local storage first, sync when online
  - Hybrid: Both paths active simultaneously

## Integration Architecture Diagram
```
+-----------------------------------------------+
|              Flutter Application               |
|                                                |
|  +----------+  +---------+  +---------------+  |
|  | Auth      |  | Session |  | Report        |  |
|  | Service   |  | Service |  | Service       |  |
|  +-----+----+  +----+----+  +-------+-------+  |
|        |             |               |           |
+--------+-------------+---------------+-----------+
         |             |               |
         | Firebase SDK (HTTPS)        |
         |             |               |
+--------+-------------+---------------+-----------+
|                Firebase Cloud                     |
|                                                   |
|  +-------------+  +-----------+  +--------------+ |
|  | Firebase     |  | Cloud     |  | Firebase     | |
|  | Auth         |  | Firestore |  | Storage      | |
|  |              |  |           |  |              | |
|  | - Login      |  | - Users   |  | - Reports    | |
|  | - Register   |  | - Sessions|  | - Face imgs  | |
|  | - JWT tokens |  | - Records |  | - Exports    | |
|  +-------------+  +-----------+  +--------------+ |
|                                                   |
+---------------------------------------------------+
```

## Authentication Flow
```
[Flutter App] --email/password--> [Firebase Auth]
                                       |
                                  Validate credentials
                                       |
                              +--------+--------+
                              |                 |
                           [Success]         [Failure]
                              |                 |
                         Return JWT          Return Error
                         + User object       + Error code
                              |                 |
                     [App stores token]    [Show error UI]
                     [Navigate to home]
```

## Data Sync Flow
```
[Local Action]
     |
     v
[Save to Local Storage]  ← ALWAYS first
     |
     v
[Check Internet]
     |
  +--+--+
  |     |
Online  Offline
  |     |
  v     v
[Upload to    [Queue for
 Firebase]     later sync]
  |
  v
[Confirm sync]
[Mark as synced]
```

## Security Rules (Firestore)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Sessions: only the creating lecturer can manage
    match /sessions/{sessionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.lecturerId;
    }
  }
}
```

## Drawing Instructions
1. Place Flutter Application at the top as a large box
2. Show internal services (Auth, Session, Report) inside the app
3. Place Firebase Cloud at the bottom as a large box
4. Show three Firebase services inside (Auth, Firestore, Storage)
5. Draw labeled arrows between app services and Firebase services
6. Show the data that flows along each arrow
7. Use the Firebase orange color scheme for cloud services

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Figma
- Microsoft Visio
