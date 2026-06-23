# Diagram 05: Class Diagram / Object-Oriented Design Structure

## Purpose
Show the object-oriented structure of the OWHAS system including classes, attributes, methods, and relationships.

## Type
**UML Class Diagram**

## Core Classes

### 1. User (Abstract/Base Class)
```
Attributes:
- userID: String (PK)
- email: String
- password: String (hashed)
- name: String
- createdDate: DateTime
- lastLogin: DateTime

Methods:
+ login()
+ logout()
+ updateProfile()
+ changePassword()
```

### 2. Lecturer (extends User)
```
Attributes:
- lecturerID: String (PK)
- department: String
- signature: Signature
- courseList: List<Course>
- defaultPIN: Integer

Methods:
+ startSession()
+ endSession()
+ configureSession()
+ generateReport()
+ uploadPreviousSession()
+ manageCourses()
```

### 3. Student (extends User)
```
Attributes:
- studentID: String (PK)
- registrationNumber: String
- program: String
- faceDescriptor: List<Double>
- deviceID: String
- attendanceRecords: List<AttendanceRecord>

Methods:
+ registerAttendance()
+ captureFace()
+ provideSignature()
+ getAttendanceHistory()
```

### 4. Session
```
Attributes:
- sessionID: String (PK)
- courseID: String (FK)
- lecturerID: String (FK)
- PIN: Integer (4-digit)
- QRCode: String
- startTime: DateTime
- endTime: DateTime (nullable)
- status: SessionStatus
- maxStudents: Integer
- gracePeriod: Integer (minutes)
- geofenceCenter: Location
- geofenceRadius: Integer (meters)
- attendanceRecords: List<AttendanceRecord>

Methods:
+ validatePIN()
+ addAttendeeRecord()
+ removeAttendee()
+ getAttendeeCount()
+ generateReport()
+ exportToCloud()
```

### 5. AttendanceRecord
```
Attributes:
- recordID: String (PK)
- sessionID: String (FK)
- studentID: String (FK)
- timestamp: DateTime
- verificationMethod: String (enum: FACE, PIN, MANUAL)
- faceConfidence: Double
- faceMatchPercentage: Double
- duplicateDetected: Boolean
- location: Location
- gpsAccuracy: Double
- deviceFingerprint: String
- signature: Signature (nullable)

Methods:
+ isFaceVerified()
+ isLocationValid()
+ isDeviceValid()
```

### 6. Course
```
Attributes:
- courseID: String (PK)
- courseCode: String
- courseName: String
- department: String
- semester: Integer
- lecturerID: String (FK)
- studentList: List<Student>
- sessionList: List<Session>

Methods:
+ addStudent()
+ removeStudent()
+ getStudentCount()
+ startNewSession()
```

### 7. FaceDescriptor
```
Attributes:
- descriptorID: String (PK)
- studentID: String (FK)
- sessionID: String (FK)
- descriptor: List<Double> (128-dimensional)
- captureTime: DateTime
- imageQuality: Double

Methods:
+ compare(FaceDescriptor): Double
+ calculateSimilarity(FaceDescriptor): Double
+ isValidDescriptor(): Boolean
```

### 8. Device
```
Attributes:
- deviceID: String (PK)
- osType: String (Android/iOS/Web)
- osVersion: String
- deviceModel: String
- fingerprint: String
- registeredStudents: List<Student>

Methods:
+ generateFingerprint()
+ isKnownDevice(): Boolean
+ flagAsSuspicious()
```

### 9. Report
```
Attributes:
- reportID: String (PK)
- sessionID: String (FK)
- reportType: String (PDF/EXCEL)
- generatedDate: DateTime
- filePath: String
- totalStudents: Integer
- presentCount: Integer
- absentCount: Integer

Methods:
+ generatePDF()
+ generateExcel()
+ upload()
+ download()
```

### 10. Location (GPS)
```
Attributes:
- locationID: String (PK)
- latitude: Double
- longitude: Double
- altitude: Double
- accuracy: Double (meters)
- timestamp: DateTime

Methods:
+ calculateDistance(Location): Double
+ isWithinGeofence(Location, radius): Boolean
```

### 11. DigitalSignature
```
Attributes:
- signatureID: String (PK)
- studentID: String (FK)
- recordID: String (FK)
- signatureData: Bitmap
- timestamp: DateTime

Methods:
+ captureSignature()
+ validateSignature(): Boolean
```

### 12. Server
```
Attributes:
- serverID: String (PK)
- ipAddress: String
- port: Integer
- status: String (RUNNING/STOPPED/ERROR)
- activeSessions: List<Session>
- database: LocalDatabase

Methods:
+ start()
+ stop()
+ validatePIN()
+ handleRegistration()
+ syncWithCloud()
+ generateReport()
```

### 13. LocalDatabase
```
Attributes:
- dbPath: String
- sessions: List<Session>
- students: List<Student>
- attendanceRecords: List<AttendanceRecord>

Methods:
+ querySession()
+ insertRecord()
+ updateRecord()
+ deleteRecord()
+ backup()
+ restore()
```

## Relationships to Show

### Associations
- Lecturer → 1..* Session (one lecturer has many sessions)
- Lecturer → 1..* Course (one lecturer has many courses)
- Session → 1..* AttendanceRecord (one session has many records)
- Student → 1..* AttendanceRecord (one student has many records)
- Course → 1..* Student (one course has many students)
- Course → 1..* Session (one course has many sessions)
- AttendanceRecord → 1..1 FaceDescriptor (one record uses one descriptor)
- Student → 1..1 Device (one student uses one device)
- Session → 1..1 Report (one session generates one report)
- Report → 1..* AttendanceRecord (report contains many records)

### Inheritance
- User (abstract) ← Lecturer
- User (abstract) ← Student

## Multiplicity Notation
- 1..1 (exactly one)
- 1..* (one or more)
- 0..* (zero or more)
- 0..1 (zero or one)

## Key Information to Display
- Class names
- Attributes with types
- Methods with return types
- Visibility modifiers (+, -, #, ~)
- Relationships with multiplicity
- Inheritance arrows
- Association labels

## Success Criteria
- All major classes visible
- Attributes and methods detailed
- Relationships clearly shown with multiplicity
- Inheritance properly indicated
- Easy to understand system structure
- Shows data types

## Tools Suitable For
- Enterprise Architect
- Lucidchart
- Visual Paradigm
- Astah
- PlantUML

## Related Sections in Final_Doc
- Section 4.2: Class Diagram / OOP Structure
- Section 5: Data Models & Database
