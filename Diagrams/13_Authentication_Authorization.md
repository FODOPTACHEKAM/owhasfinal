# Diagram 13: Authentication & Authorization Sequence

## Purpose
Show the authentication and authorization flows for both offline (hotspot) and online (cloud) modes.

## Type
**Sequence Diagram** (with multiple swimlanes for different paths)

## Path 1: Offline Session Authentication (Hotspot Mode)

```
OFFLINE MODE: Lecturer starts session with local hotspot
================================================

Lecturer: Opens Flutter app
  |
  ├─→ Flutter App: Display courses
  |
Lecturer: Selects course → Configure → Start session
  |
  ├─→ Flutter App: Prepare session start
  |
  ├─→ Node.js Server: POST /api/session/start
  |       {lecturerID, courseID, PIN: "1234", duration, geofence}
  |       |
  |       ├─→ Server: Validate lecturer credentials (local)
  |       │   - Check lecturerID exists
  |       │   - Verify session configuration
  |       |
  |       ├─→ Local Database: Save new Session
  |       │   - sessionID: unique
  |       │   - PIN: "1234" (stored encrypted)
  |       │   - status: ACTIVE
  |       |
  |       ├─← Server: Return {sessionID, QR_token}
  |
  ├─← Flutter App: Display PIN and QR
  |
Lecturer: Broadcasts PIN verbally or displays on projector
  |
  ├─→ Hotspot: Students connect to WiFi SSID
  |
  ├─→ Browser: Captive portal opens hotspot.html
  |
Student: Enters PIN "1234"
  |
  ├─→ Browser: POST /api/attendance/verify-pin
  |       {PIN: "1234", deviceID}
  |       |
  |       ├─→ Server: Retrieve active sessions
  |       ├─→ Server: Find session with matching PIN
  |       ├─→ Server: Validate PIN = "1234" (decrypt and compare)
  |       |
  |       ├─ If match:
  |       │   ├─→ Server: Generate session token (JWT-like)
  |       │   │   - Token contains: sessionID, timestamp, expiry
  |       │   │   - Not cryptographically signed (optional)
  |       │   └─← Server: Return {token, sessionID, sessionInfo}
  |       |
  |       └─ If no match:
  |           └─← Server: Return {error: "Invalid PIN"}
  |
  ├─← Browser: Store token in sessionStorage (temporary)
  |
Student: Face registration proceeds with valid token
  |
  ├─→ Browser: Include token in all subsequent requests
  │   POST /api/attendance/register { token, faceDescriptor, ... }
  |
  ├─→ Server: Validate token still valid
  |       ├─ Check expiry (session duration)
  |       ├─ Check sessionID matches active session
  |       └─ Proceed if valid
  |
  ├─→ Local Database: Create AttendanceRecord
  |
END (Student registered in offline mode)
```

## Path 2: Online Session Authentication (Cloud Mode with Firebase)

```
ONLINE MODE: Lecturer signs in to cloud account
===================================================

Lecturer: Opens Flutter app
  |
  ├─→ Flutter App: Check Firebase sign-in status
  |       ├─ If not signed in → Show login screen
  |       └─ If signed in → Skip to session creation
  |
Lecturer: (if needed) Enters email and password
  |
  ├─→ Flutter App: Firebase.Auth.signInWithEmailPassword()
  |
  ├─→ Firebase Authentication Service
  |       ├─ Validate email format
  |       ├─ Retrieve user record from Firebase
  |       ├─ Verify password (bcrypt comparison)
  |       ├─ Check if MFA enabled (optional)
  |       └─ Return: {userUID, idToken, refreshToken}
  |
  ├─← Flutter App: Receive idToken and refreshToken
  |
  ├─→ Flutter App: Store tokens securely
  |       - idToken: JWT (expires in 1 hour)
  |       - refreshToken: Long-lived (stored securely)
  |
Lecturer: Session is now authenticated to Firebase
  |
Lecturer: Selects course → Configures → Starts session
  |
  ├─→ Flutter App: Prepare session start
  |
  ├─→ Flutter App: Attach idToken to request
  |
  ├─→ Node.js Server: POST /api/session/start
  |       {courseID, PIN, duration, idToken: "eyJhbc..."}
  |       |
  |       ├─→ Server: Verify idToken with Firebase
  |       │   - Check signature (verify against Firebase public key)
  |       │   - Check expiry
  |       │   - Extract userUID from token
  |       │   - Verify userUID has lecturer role
  |       |
  |       ├─ If token invalid:
  |       │   └─← Server: Return {error: "Unauthorized", code: 401}
  |       |
  |       └─ If token valid:
  |           ├─→ Server: Create session in cloud (Firestore)
  |           ├─→ Server: Also save to local database (hybrid)
  |           └─← Server: Return {sessionID, QR, PIN}
  |
  ├─← Flutter App: Display session created
  |
Lecturer: Session is now available both locally and in cloud
  |
Student: Joins via web portal or cloud-provided link
  |
  ├─→ Browser: Redirect to registration page
  |
  ├─→ Firebase Authentication (client-side)
  |       - May require student to sign in OR
  |       - Allow anonymous access (depends on config)
  |
  ├─ If anonymous access allowed:
  |   └─→ Student: Proceeds without Firebase login
  |       (Uses PIN to access specific session)
  |
  └─ If login required:
      └─→ Student: Must authenticate with Firebase first
          (Similar process as lecturer)
```

## Path 3: Hybrid Mode (Both Offline and Online)

```
HYBRID MODE: Lecturer enables both local and cloud
===================================================

Lecturer: Signed in to Firebase (has valid idToken)
  |
  ├─→ Starts session with local hotspot AND cloud
  |
  ├─→ Node.js Server: POST /api/session/start
  |       {courseID, PIN, duration, idToken, mode: "hybrid"}
  |       |
  |       ├─→ Server: Verify idToken (cloud auth)
  |       ├─→ Local Database: Create Session (local auth)
  |       ├─→ Firestore: Create Session document (cloud)
  |       └─ Session registered in BOTH places
  |
Local Students: Connect to hotspot WiFi
  |
  ├─→ PIN-based authentication (offline path)
  |
Cloud Students: Connect via owhas.org
  |
  ├─→ Token-based authentication (online path)
  |
Both: Can register attendance
  |
  ├─→ Server: Routes request to appropriate backend
  |       ├─ Local hotspot request? → Local DB
  |       └─ Cloud request? → Firestore
  |
  ├─→ Server: Syncs data between local and cloud
  |
END (Hybrid session with both paths active)
```

## Path 4: Token Refresh and Expiry

```
TOKEN LIFECYCLE
===============

Token Issued:
  ├─ idToken (short-lived): 1 hour expiry
  └─ refreshToken (long-lived): 7 days expiry
  |
[During Session - Less than 1 hour]
  |
  ├─ Token remains valid
  ├─ All requests accepted with valid token
  └─ No action needed
  |
[Session Duration > 1 Hour - Token Expires]
  |
  ├─→ Flutter App: Detects token expiry
  │   (From error response: 401 Unauthorized)
  |
  ├─→ Flutter App: Attempt token refresh
  |
  ├─→ Firebase Auth: POST /refresh
  |       {refreshToken}
  |       |
  |       ├─ Check refreshToken validity
  |       ├─ If valid → Generate new idToken
  |       └─ If expired → Require re-login
  |
  ├─← Firebase: Return new idToken
  |
  ├─→ Flutter App: Update stored token
  |
  ├─→ Flutter App: Retry original request with new token
  |
  └─ Session continues seamlessly
  |
[No Activity for 7+ Days]
  |
  ├─ refreshToken expires
  ├─ Next login attempt fails
  └─ Require full re-authentication
```

## Token Content (JWT Structure - Online Mode)

### ID Token Payload (Decoded)
```json
{
  "iss": "https://securetoken.google.com/project-id",
  "aud": "project-id",
  "auth_time": 1699564234,
  "user_id": "user123abc",
  "sub": "user123abc",
  "iat": 1699567834,
  "exp": 1699571434,
  "email": "lecturer@university.edu",
  "email_verified": true,
  "firebase": {
    "identities": {
      "email": ["lecturer@university.edu"]
    }
  }
}
```

### Session Token Payload (Offline Mode - Custom)
```json
{
  "sessionID": "sess-abc123",
  "PIN": "1234",
  "issuedAt": 1699567834,
  "expiresAt": 1699575034,  // 2 hours
  "courseID": "CSE101"
}
```

## Authorization Checks (Role-Based Access)

### Lecturer Authorization
```
Condition: Has active session?
  ├─ NO → Cannot access session endpoints
  └─ YES → Can access:
      ├─ /api/session/{id}/dashboard (view)
      ├─ /api/session/{id}/end (update)
      ├─ /api/session/{id}/report (download)
      └─ /api/attendance/{sessionId}/remove (delete)
```

### Student Authorization
```
Condition: Has valid PIN or token for session?
  ├─ NO → Cannot register attendance
  └─ YES → Can access:
      ├─ /api/attendance/verify-pin (verify)
      ├─ /api/attendance/verify-face (verify)
      ├─ /api/attendance/register (create)
      └─ Limited to current session only
```

### Admin Authorization (Optional)
```
Condition: Has admin credentials + valid token?
  ├─ NO → Cannot access admin endpoints
  └─ YES → Can access:
      ├─ /api/users (manage users)
      ├─ /api/sessions/all (view all)
      ├─ /api/reports/archive (manage)
      └─ /api/security/logs (audit)
```

## Session Timeout Handling

### Offline Mode
```
- Session timeout: Based on configured duration
  (e.g., 2 hours for typical class)
- PIN becomes invalid after timeout
- Late joiners: Cannot register after timeout
- Extension: Lecturer can manually extend (optional)
```

### Online Mode
```
- Token expiry: Automatic (Firebase handles)
- Session timeout: Can be different from token expiry
- Refresh token: Provides seamless continuation
- Timeout: May require re-authentication after N hours
```

## Security Headers (All Modes)

```
HTTP Headers sent with responses:
- Strict-Transport-Security (HTTPS only)
- X-Content-Type-Options (prevent MIME sniffing)
- X-Frame-Options (prevent clickjacking)
- Content-Security-Policy (prevent XSS)
- X-XSS-Protection (legacy XSS protection)
```

## Success Criteria
- Both offline and online auth paths clear
- Hybrid mode shows dual authentication
- Token lifecycle visible
- Expiry and refresh shown
- Authorization rules clear
- Role-based access distinguished
- Session management shown
- Error handling visible

## Tools Suitable For
- Draw.io
- Lucidchart
- Enterprise Architect
- PlantUML (sequence diagram)
- Visual Paradigm

## Related Sections in Final_Doc
- Section 7.2: Authentication Flow
- Section 7: Security & Authentication
