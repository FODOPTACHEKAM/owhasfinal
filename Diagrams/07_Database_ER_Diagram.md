# Diagram 07: Database Schema - Entity-Relationship (ER) Diagram

## Purpose
Show the database structure including all tables, fields, and relationships for OWHAS system.

## Type
**Entity-Relationship Diagram (ERD)**

## Entities and Attributes

### 1. Users Table
```
PK: userID (UUID)
- email (VARCHAR, UNIQUE)
- passwordHash (VARCHAR, encrypted)
- firstName (VARCHAR)
- lastName (VARCHAR)
- userType (ENUM: lecturer, student, admin)
- createdDate (TIMESTAMP)
- lastLogin (TIMESTAMP)
- isActive (BOOLEAN)
- profilePhotoURL (VARCHAR)
```

### 2. Lecturers Table
```
PK: lecturerID (UUID)
FK: userID → Users.userID
- department (VARCHAR)
- employeeNumber (VARCHAR)
- office (VARCHAR)
- phoneNumber (VARCHAR)
- signatureImageURL (VARCHAR)
```

### 3. Students Table
```
PK: studentID (UUID)
FK: userID → Users.userID
- registrationNumber (VARCHAR, UNIQUE)
- program (VARCHAR)
- year (INTEGER)
- enrolledCourses (reference to Enrollments table)
```

### 4. Courses Table
```
PK: courseID (UUID)
FK: lecturerID → Lecturers.lecturerID
- courseCode (VARCHAR, UNIQUE)
- courseName (VARCHAR)
- department (VARCHAR)
- semester (INTEGER)
- academicYear (VARCHAR)
- creditHours (INTEGER)
- description (TEXT)
- createdDate (TIMESTAMP)
```

### 5. Enrollments Table (Course-Student join)
```
PK: enrollmentID (UUID)
FK: courseID → Courses.courseID
FK: studentID → Students.studentID
- enrolledDate (TIMESTAMP)
- status (ENUM: active, withdrawn, completed)
```

### 6. Sessions Table
```
PK: sessionID (UUID)
FK: courseID → Courses.courseID
FK: lecturerID → Lecturers.lecturerID
- sessionNumber (INTEGER)
- PIN (VARCHAR, 4-digit, encrypted)
- QRCode (TEXT)
- sessionDate (DATE)
- startTime (TIMESTAMP)
- endTime (TIMESTAMP)
- status (ENUM: not_started, active, paused, ended, exported, synced)
- maxStudents (INTEGER)
- gracePeriod (INTEGER, in minutes)
- geofenceLatitude (DECIMAL)
- geofenceLongitude (DECIMAL)
- geofenceRadius (INTEGER, in meters)
- location (VARCHAR)
```

### 7. AttendanceRecords Table
```
PK: recordID (UUID)
FK: sessionID → Sessions.sessionID
FK: studentID → Students.studentID
FK: deviceID → Devices.deviceID
- registrationTime (TIMESTAMP)
- verificationMethod (ENUM: face, pin, manual, qr)
- faceConfidence (DECIMAL, 0-100)
- faceMatchPercentage (DECIMAL, 0-100)
- duplicateDetected (BOOLEAN)
- duplicateOf (UUID, FK to same table if duplicate)
- latitude (DECIMAL)
- longitude (DECIMAL)
- gpsAccuracy (DECIMAL, in meters)
- isLocationVerified (BOOLEAN)
- signatureImageURL (VARCHAR)
- notes (TEXT)
- createdAt (TIMESTAMP)
```

### 8. FaceDescriptors Table
```
PK: descriptorID (UUID)
FK: studentID → Students.studentID
FK: sessionID → Sessions.sessionID
- faceDescriptor (JSON, 128-dimensional array)
- imageURL (VARCHAR)
- imageQuality (DECIMAL, 0-100)
- captureTime (TIMESTAMP)
- cameraDevice (VARCHAR)
```

### 9. Devices Table
```
PK: deviceID (VARCHAR, fingerprint hash)
FK: primaryStudent → Students.studentID (nullable)
- osType (ENUM: Android, iOS, Web)
- osVersion (VARCHAR)
- deviceModel (VARCHAR)
- deviceName (VARCHAR)
- uniqueIdentifier (VARCHAR)
- firstSeen (TIMESTAMP)
- lastSeen (TIMESTAMP)
- isSuspicious (BOOLEAN)
- isBanned (BOOLEAN)
- banReason (TEXT)
```

### 10. Reports Table
```
PK: reportID (UUID)
FK: sessionID → Sessions.sessionID
FK: lecturerID → Lecturers.lecturerID
- reportType (ENUM: pdf, excel, json)
- generatedDate (TIMESTAMP)
- totalStudents (INTEGER)
- presentCount (INTEGER)
- absentCount (INTEGER)
- fileSize (INTEGER, in bytes)
- fileURL (VARCHAR)
- checksum (VARCHAR)
- synced (BOOLEAN)
- cloudURL (VARCHAR)
```

### 11. GPSLocations Table
```
PK: locationID (UUID)
FK: recordID → AttendanceRecords.recordID (nullable)
- latitude (DECIMAL)
- longitude (DECIMAL)
- altitude (DECIMAL)
- accuracy (DECIMAL, in meters)
- timestamp (TIMESTAMP)
- provider (VARCHAR: GPS, Network, Fused)
```

### 12. DigitalSignatures Table
```
PK: signatureID (UUID)
FK: recordID → AttendanceRecords.recordID
FK: studentID → Students.studentID
- signatureData (BLOB, image binary)
- signatureFormat (VARCHAR: PNG, JPEG)
- timestamp (TIMESTAMP)
- isVerified (BOOLEAN)
```

### 13. Sessions_Archive Table (Historical sessions)
```
PK: archiveID (UUID)
FK: sessionID → Sessions.sessionID
- archivedDate (TIMESTAMP)
- archiveReason (VARCHAR)
- backupURL (VARCHAR)
```

### 14. AuditLogs Table (System audit trail)
```
PK: logID (UUID)
FK: userID → Users.userID (nullable)
FK: sessionID → Sessions.sessionID (nullable)
- action (VARCHAR)
- tableName (VARCHAR)
- recordID (UUID)
- oldValue (JSON)
- newValue (JSON)
- timestamp (TIMESTAMP)
- ipAddress (VARCHAR)
```

## Relationships

### One-to-Many (1:N)
- Lecturers → Courses (1 lecturer teaches many courses)
- Lecturers → Sessions (1 lecturer conducts many sessions)
- Courses → Sessions (1 course has many sessions)
- Sessions → AttendanceRecords (1 session has many records)
- Students → AttendanceRecords (1 student has many records)
- Students → FaceDescriptors (1 student has many face captures)
- Sessions → Reports (1 session generates multiple reports)
- Devices → AttendanceRecords (1 device used for many registrations)

### Many-to-Many (N:M)
- Courses ↔ Students via Enrollments table
- Students ↔ Sessions (through AttendanceRecords)

### One-to-One (1:1)
- Users ↔ Lecturers (if lecturer is user type)
- Users ↔ Students (if student is user type)

## Indexes to Create
- ON Sessions (courseID, sessionDate)
- ON AttendanceRecords (sessionID, studentID, recordID)
- ON AttendanceRecords (registrationTime)
- ON Students (registrationNumber)
- ON Courses (courseCode)
- ON Users (email)
- ON Devices (deviceID, lastSeen)
- ON FaceDescriptors (studentID, sessionID)

## Key Constraints
- PRIMARY KEY on all PK fields
- FOREIGN KEY constraints for referential integrity
- UNIQUE on email, registrationNumber, courseCode
- NOT NULL on essential fields (userID, sessionID, etc.)
- CHECK constraints on ENUM fields

## Success Criteria
- All entities shown with clear labels
- All attributes displayed
- Primary keys identified
- Foreign keys with arrows showing relationships
- Multiplicity/cardinality shown (1:1, 1:N, N:M)
- Relationship names labeled
- Indexes and constraints indicated
- Normalized design (no redundant data)

## Tools Suitable For
- Lucidchart
- Draw.io
- DbDiagram.io
- DBeaver (if reverse engineering)
- MySQL Workbench
- PostgreSQL pgAdmin

## Related Sections in Final_Doc
- Section 5.1: Entity-Relationship Diagram
- Section 5: Data Models & Database
