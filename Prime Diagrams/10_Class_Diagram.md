# Figure 4.10: Class Diagram

## Purpose
Shows the object-oriented design of OwHAS with classes, attributes, methods, and relationships.

## Diagram Type
**UML Class Diagram**

## Classes

### 1. User (Abstract)
```
+----------------------------------+
|          <<abstract>>            |
|             User                 |
+----------------------------------+
| - id: String                     |
| - name: String                   |
| - email: String                  |
| - createdAt: DateTime            |
+----------------------------------+
| + getId(): String                |
| + getName(): String              |
| + getEmail(): String             |
| + toJson(): Map                  |
| + fromJson(json): User           |
+----------------------------------+
```

### 2. Lecturer (extends User)
```
+----------------------------------+
|           Lecturer               |
+----------------------------------+
| - courseList: List<Course>        |
| - signature: String              |
| - firebaseUid: String            |
| - profileImageUrl: String        |
+----------------------------------+
| + createSession(): Session       |
| + endSession(id): void           |
| + generateReport(session): File  |
| + syncToCloud(): void            |
| + getCourses(): List<Course>     |
+----------------------------------+
```

### 3. Student
```
+----------------------------------+
|           Student                |
+----------------------------------+
| - name: String                   |
| - matricNumber: String           |
| - email: String                  |
| - faceDescriptor: List<double>   |
| - deviceId: String               |
| - registeredAt: DateTime         |
| - signatureData: String          |
+----------------------------------+
| + register(session): void        |
| + getFaceDescriptor(): List      |
| + getDeviceInfo(): DeviceInfo    |
| + toJson(): Map                  |
+----------------------------------+
```

### 4. AttendanceSession
```
+----------------------------------+
|       AttendanceSession          |
+----------------------------------+
| - id: String                     |
| - courseId: String               |
| - courseName: String             |
| - pin: String                    |
| - startTime: DateTime            |
| - endTime: DateTime              |
| - duration: int                  |
| - status: SessionStatus          |
| - lecturerId: String             |
| - geofenceCenter: GeoPoint       |
| - geofenceRadius: double         |
| - attendees: List<AttendanceRec> |
+----------------------------------+
| + start(): void                  |
| + end(): void                    |
| + pause(): void                  |
| + resume(): void                 |
| + generatePin(): String          |
| + getAttendeeCount(): int        |
| + isActive(): bool               |
| + toJson(): Map                  |
+----------------------------------+
```

### 5. AttendanceRecord
```
+----------------------------------+
|       AttendanceRecord           |
+----------------------------------+
| - id: String                     |
| - sessionId: String              |
| - studentName: String            |
| - matricNumber: String           |
| - timestamp: DateTime            |
| - faceDescriptor: List<double>   |
| - faceVerified: bool             |
| - isDuplicate: bool              |
| - deviceFingerprint: String      |
| - gpsLocation: GeoPoint          |
| - signatureData: String          |
+----------------------------------+
| + verify(): bool                 |
| + markDuplicate(): void          |
| + toJson(): Map                  |
| + fromJson(json): AttendanceRec  |
+----------------------------------+
```

### 6. SessionService
```
+----------------------------------+
|        SessionService            |
+----------------------------------+
| - currentSession: Session        |
| - serverConfig: ServerConfig     |
+----------------------------------+
| + createSession(config): Session |
| + startSession(id): void         |
| + endSession(id): void           |
| + getSession(id): Session        |
| + getAllSessions(): List<Session> |
| + validatePin(pin): bool         |
+----------------------------------+
```

### 7. AttendanceService
```
+----------------------------------+
|       AttendanceService          |
+----------------------------------+
| - attendeeList: List<Record>     |
| - faceService: FaceService       |
+----------------------------------+
| + registerStudent(data): Record  |
| + getAttendees(sessionId): List  |
| + checkDuplicate(face): bool     |
| + getAttendeeCount(): int        |
| + exportAttendees(): List<Map>   |
+----------------------------------+
```

### 8. StorageService
```
+----------------------------------+
|        StorageService            |
+----------------------------------+
| - basePath: String               |
+----------------------------------+
| + saveSession(session): void     |
| + loadSession(id): Session       |
| + saveAttendance(record): void   |
| + loadAttendance(sid): List      |
| + saveReport(file): String       |
| + deleteSession(id): void        |
+----------------------------------+
```

### 9. CloudService
```
+----------------------------------+
|         CloudService             |
+----------------------------------+
| - firestore: Firestore           |
| - auth: FirebaseAuth             |
| - storage: FirebaseStorage       |
+----------------------------------+
| + login(email, pass): User       |
| + logout(): void                 |
| + syncSession(session): void     |
| + syncAttendance(records): void  |
| + uploadReport(file): String     |
| + isConnected(): bool            |
+----------------------------------+
```

## Relationships

| From | To | Type | Multiplicity | Description |
|------|----|------|-------------|-------------|
| Lecturer | User | Inheritance | — | Lecturer extends User |
| Lecturer | AttendanceSession | Association | 1 : N | Lecturer creates many sessions |
| AttendanceSession | AttendanceRecord | Composition | 1 : N | Session contains many records |
| Student | AttendanceRecord | Association | 1 : N | Student has many attendance records |
| AttendanceSession | Course | Association | N : 1 | Many sessions belong to one course |
| SessionService | AttendanceSession | Dependency | — | Manages session lifecycle |
| AttendanceService | AttendanceRecord | Dependency | — | Manages attendance records |
| AttendanceService | FaceService | Dependency | — | Uses face verification |
| StorageService | AttendanceSession | Dependency | — | Persists session data |
| CloudService | StorageService | Dependency | — | Syncs local to cloud |

## Enumerations

### SessionStatus
```
<<enumeration>>
SessionStatus
- NOT_STARTED
- ACTIVE
- PAUSED
- ENDED
- EXPORTED
- SYNCED
```

## Drawing Instructions
1. Draw each class as a three-section rectangle (name / attributes / methods)
2. Use visibility markers: + public, - private, # protected
3. Draw inheritance arrows (hollow triangle head) from Lecturer to User
4. Draw composition diamonds (filled) from Session to AttendanceRecord
5. Label all associations with multiplicity (1, N, 1..*)
6. Group service classes separately from domain classes

## Tools
- Draw.io / diagrams.net
- Lucidchart
- StarUML
- Visual Paradigm
- PlantUML
