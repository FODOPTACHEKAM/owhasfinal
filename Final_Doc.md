# OwHAS — Offline Wi-Fi Hotspot Attendance System
## Final Year Project Documentation

**Student Name:** [INSERT STUDENT NAME]
**Matriculation Number:** [INSERT MATRIC NUMBER]
**Programme:** [INSERT PROGRAMME NAME]
**Department:** [INSERT DEPARTMENT]
**Institution:** ICT University (ICTU)
**Supervisor:** [INSERT SUPERVISOR NAME]
**Academic Year:** [INSERT ACADEMIC YEAR]
**Date Submitted:** [INSERT DATE]

---

## Table of Contents

1. [Abstract](#1-abstract)
2. [Introduction](#2-introduction)
3. [Problem Statement](#3-problem-statement)
4. [Objectives](#4-objectives)
5. [Literature Review](#5-literature-review)
6. [Methodology](#6-methodology)
7. [System Analysis & Requirements](#7-system-analysis--requirements)
8. [System Design](#8-system-design)
9. [System Implementation](#9-system-implementation)
10. [Testing & Validation](#10-testing--validation)
11. [Results & Discussion](#11-results--discussion)
12. [Deployment](#12-deployment)
13. [Limitations & Challenges](#13-limitations--challenges)
14. [Future Work](#14-future-work)
15. [Conclusion](#15-conclusion)
16. [References](#16-references)
17. [Appendices](#17-appendices)

---

## List of Figures

| Figure | Title | Page |
|--------|-------|------|
| Figure 4.1 | System Context Diagram | |
| Figure 4.2 | Hotspot Network Topology | |
| Figure 4.3 | Overall System Architecture | |
| Figure 4.4 | Use Case Diagram | |
| Figure 4.5 | Attendance Registration Activity Diagram | |
| Figure 4.6 | QR Check-In Flowchart | |
| Figure 4.7 | Captive Portal Workflow | |
| Figure 4.8 | Attendance Registration Sequence Diagram | |
| Figure 4.9 | Component Diagram | |
| Figure 4.10 | Class Diagram | |
| Figure 4.11 | Entity Relationship Diagram | |
| Figure 4.12 | Deployment Diagram | |
| Figure 4.13 | Offline-First Synchronization Diagram | |
| Figure 4.14 | Device Fingerprinting Process | |
| Figure 4.15 | Firebase Integration Architecture | |

## List of Tables

| Table | Title | Page |
|-------|-------|------|
| Table 1 | Functional Requirements | |
| Table 2 | Non-Functional Requirements | |
| Table 3 | Technology Stack | |
| Table 4 | Core Data Models | |
| Table 5 | API Endpoints | |
| Table 6 | Test Scenarios & Results | |
| Table 7 | Deployment Options Comparison | |
| Table 8 | Performance Benchmarks | |

## List of Abbreviations

| Abbreviation | Full Form |
|-------------|-----------|
| OwHAS | Offline Wi-Fi Hotspot Attendance System |
| OOP | Object-Oriented Programming |
| UML | Unified Modeling Language |
| API | Application Programming Interface |
| GPS | Global Positioning System |
| QR | Quick Response (code) |
| PIN | Personal Identification Number |
| ERD | Entity-Relationship Diagram |
| PDF | Portable Document Format |
| JWT | JSON Web Token |
| HTTPS | Hypertext Transfer Protocol Secure |
| VLAN | Virtual Local Area Network |
| LAN | Local Area Network |
| SDK | Software Development Kit |
| CRUD | Create, Read, Update, Delete |

---

## 1. Abstract

**[INSERT ABSTRACT — 200-300 words]**

OwHAS (Offline Wi-Fi Hotspot Attendance System) is a cross-platform mobile application built with Flutter that enables lecturers to manage student attendance digitally without requiring a permanent internet connection. The system leverages the lecturer's device as a Wi-Fi hotspot, creating a local area network (LAN) over which a Node.js server runs and hosts a web registration page. Students connect to this hotspot and submit their attendance through a browser — no app installation required on the student side.

The system supports three operational modes: fully offline (hotspot), fully online (cloud server), and hybrid (both simultaneously). It incorporates face recognition for anti-proxy detection, a 4-digit PIN for session authentication, GPS-based geolocation verification for online sessions, digital signature capture, Firebase cloud backup, cumulative attendance tracking across multiple sessions, and automated PDF and Excel report generation.

**Keywords:** Attendance Management, Offline-First, Wi-Fi Hotspot, Face Recognition, Flutter, Node.js, Firebase, Anti-Proxy, Captive Portal

---

## 2. Introduction

### 2.1 Background

**[INSERT: Background on attendance management in higher education]**

Traditional attendance management in educational institutions relies on paper-based sign-in sheets, manual roll calls, or centralized software systems that depend on institutional internet infrastructure. These methods suffer from common problems: they are slow, prone to proxy attendance, easily forged, difficult to archive, and non-functional when internet access is unavailable.

### 2.2 Motivation

**[INSERT: Personal motivation and context for this project]**

### 2.3 Project Scope

**[INSERT: What is included and excluded from this project]**

**Included:**
- Mobile application for lecturers (Flutter)
- Web registration portal for students (HTML/JS)
- Offline hotspot-based attendance
- Online cloud-based attendance
- Face recognition anti-proxy system
- GPS geofencing (online mode)
- PDF and Excel report generation
- Firebase cloud backup

**Excluded:**
- Student-side mobile application
- Integration with existing Student Information Systems (SIS)
- Biometric fingerprint scanning
- Video-based verification

### 2.4 Document Structure

This document is organized as follows:
- **Chapters 1-4:** Introduction, problem statement, objectives, and literature review
- **Chapters 5-6:** Methodology and system analysis
- **Chapters 7-8:** System design (with all diagrams) and implementation
- **Chapters 9-11:** Testing, results, and deployment
- **Chapters 12-15:** Limitations, future work, conclusion, and references

---

## 3. Problem Statement

### 3.1 Problem Description

**[INSERT: Detailed problem statement]**

Attendance management in higher education faces several persistent challenges:

**Proxy Attendance:** Students signing in on behalf of absent classmates is a widespread issue that paper sheets and simple digital forms cannot prevent.

**Infrastructure Dependency:** Web-based attendance systems require reliable internet or intranet access. Many lecture halls and fieldwork locations lack stable connectivity.

**Data Loss:** Paper sheets are easily lost or damaged. Locally stored digital data is lost if the device fails without a backup.

**Manual Processing:** Converting raw sign-in data into meaningful attendance reports requires significant manual effort.

**Scalability:** A system that works for 20 students must also work for 200 without performance degradation.

### 3.2 Research Questions

**[INSERT: Research questions this project addresses]**

1. How can attendance be reliably captured in environments without internet access?
2. How can proxy attendance be prevented using biometric verification?
3. How can an attendance system balance offline functionality with cloud backup?
4. How can automated reporting reduce the manual workload for lecturers?

---

## 4. Objectives

### 4.1 General Objective

**[INSERT: The overarching goal of the project]**

To design and implement an offline-first attendance management system that operates independently of institutional internet infrastructure while providing anti-proxy measures and automated reporting.

### 4.2 Specific Objectives

**[INSERT: 4-6 specific, measurable objectives]**

1. To develop a Flutter-based mobile application that enables lecturers to create and manage attendance sessions
2. To implement a Wi-Fi hotspot-based local server that captures student attendance without internet
3. To integrate face recognition (face-api.js) for anti-proxy detection with a 0.45 similarity threshold
4. To implement automated PDF and Excel report generation with cumulative attendance tracking
5. To enable cloud synchronization via Firebase for data backup and cross-device access
6. To support multiple deployment modes: offline (hotspot), online (cloud), and institutional (VLAN)

---

## 5. Literature Review

### 5.1 Existing Attendance Management Systems

**[INSERT: Review of existing systems — paper-based, RFID, biometric, app-based]**

### 5.2 Offline-First Architecture

**[INSERT: Review of offline-first design patterns and their applications]**

### 5.3 Face Recognition in Education

**[INSERT: Review of face recognition technology applied to attendance]**

### 5.4 Captive Portal Technology

**[INSERT: Review of captive portal mechanisms and their use in attendance systems]**

### 5.5 Related Work Comparison

**[INSERT: Comparison table of existing systems vs. OwHAS]**

| Feature | Paper-Based | RFID | Existing Apps | OwHAS |
|---------|-------------|------|---------------|-------|
| Internet Required | No | No | Yes | No (offline mode) |
| Proxy Prevention | None | Low | Medium | High (face + device) |
| Cost | Low | High | Medium | Low |
| Auto Reports | No | Partial | Yes | Yes |
| Offline Support | Yes | Yes | No | Yes |
| Cloud Backup | No | No | Yes | Yes |

### 5.6 Gap Analysis

**[INSERT: What gaps in existing solutions OwHAS addresses]**

---

## 6. Methodology

### 6.1 Development Methodology

**[INSERT: SDLC model used — Agile, Iterative, etc.]**

### 6.2 Tools and Technologies

**Table 3: Technology Stack**

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Frontend | Flutter | 3.x | Cross-platform mobile application |
| Language | Dart | 3.x | Flutter programming language |
| Backend | Node.js | 14+ | Server-side runtime |
| Framework | Express.js | 4.x | HTTP server framework |
| Face Recognition | face-api.js | 0.22.2 | Face detection and comparison |
| Database (Local) | JSON files | — | Offline data storage |
| Database (Cloud) | Cloud Firestore | — | Cloud document database |
| Authentication | Firebase Auth | — | User login/signup |
| File Storage | Firebase Storage | — | Cloud file storage |
| PDF Generation | pdf (Dart) | — | PDF report generation |
| Excel Generation | excel (Dart) | — | Excel spreadsheet generation |
| QR Code | qr_flutter | — | QR code generation |
| IDE | VS Code / Android Studio | — | Development environment |
| Version Control | Git / GitHub | — | Source code management |

### 6.3 Data Collection Methods

**[INSERT: How requirements were gathered — interviews, observation, etc.]**

---

## 7. System Analysis & Requirements

### 7.1 Functional Requirements

**Table 1: Functional Requirements**

| ID | Requirement | Priority | Description |
|----|------------|----------|-------------|
| FR-01 | Lecturer Authentication | High | Lecturers can login/register with email and password |
| FR-02 | Session Creation | High | Lecturers can create attendance sessions with course, PIN, and duration |
| FR-03 | QR Code Generation | High | System generates QR codes for session access |
| FR-04 | Student Registration | High | Students can register attendance via web browser |
| FR-05 | PIN Validation | High | 4-digit PIN validates session access |
| FR-06 | Face Capture | High | Students capture face image during registration |
| FR-07 | Face Verification | High | System detects duplicate faces (anti-proxy) |
| FR-08 | Live Dashboard | Medium | Lecturers view real-time attendee list and count |
| FR-09 | Report Generation | High | System generates PDF and Excel reports |
| FR-10 | Cloud Sync | Medium | Data syncs to Firebase when internet is available |
| FR-11 | GPS Geofencing | Medium | Online mode verifies student location |
| FR-12 | Digital Signature | Low | Optional signature capture for additional verification |
| FR-13 | Cumulative Tracking | Medium | Track attendance across multiple sessions per course |
| FR-14 | Offline Operation | High | Full functionality without internet |

### 7.2 Non-Functional Requirements

**Table 2: Non-Functional Requirements**

| ID | Requirement | Description |
|----|------------|-------------|
| NFR-01 | Performance | Registration completes in under 3 seconds |
| NFR-02 | Scalability | Support up to 50 concurrent students (offline) or 200+ (online) |
| NFR-03 | Reliability | No data loss during offline operation |
| NFR-04 | Usability | Students need no app installation or training |
| NFR-05 | Security | Face verification prevents proxy attendance |
| NFR-06 | Compatibility | Works on Android 8+, iOS 13+, modern browsers |
| NFR-07 | Availability | Works without internet (offline-first design) |

### 7.3 Use Case Analysis

**[INSERT: Detailed use case descriptions for key use cases]**

---

## 8. System Design

This chapter presents the complete system design through 15 diagrams. Each diagram illustrates a different aspect of the OwHAS architecture, behavior, and data design.

---

### 8.1 System Context Diagram

**Figure 4.1: System Context Diagram**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│         [INSERT CONTEXT DIAGRAM HERE]           │
│                                                 │
│  Actors:                                        │
│  • Lecturer (creates sessions, views reports)   │
│  • Student (registers attendance)               │
│  • Firebase Cloud (authentication, sync)        │
│  • Node.js Server (processes registrations)     │
│                                                 │
│  See: Prime Diagrams/01_Context_Diagram.md      │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The context diagram shows OwHAS as a single system interacting with four external entities. The Lecturer provides session configuration and receives attendance reports. Students submit registration data and receive confirmation. Firebase Cloud provides authentication services and receives synced data. The Node.js Server hosts the registration portal and processes attendance submissions.

---

### 8.2 Network Topology Diagram

**Figure 4.2: Hotspot Network Topology**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│      [INSERT NETWORK TOPOLOGY DIAGRAM HERE]     │
│                                                 │
│  Components:                                    │
│  • Lecturer Smartphone/Laptop (hotspot host)    │
│  • Wi-Fi Hotspot (local network)                │
│  • Student Smartphones & Laptops                │
│  • Node.js Server (localhost:8080)              │
│  • Firebase Cloud (optional, via internet)      │
│                                                 │
│  See: Prime Diagrams/02_Network_Topology.md     │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The network topology illustrates three deployment configurations. In offline mode, the lecturer's device creates a Wi-Fi hotspot and runs the Node.js server locally. Student devices connect as Wi-Fi clients and access the registration page via HTTP on port 8080. In online mode, all devices connect through the internet to a cloud server. In institutional mode, devices communicate over a school VLAN to a dedicated server.

---

### 8.3 Overall System Architecture

**Figure 4.3: Overall System Architecture**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│    [INSERT SYSTEM ARCHITECTURE DIAGRAM HERE]    │
│                                                 │
│  Layers:                                        │
│  1. Presentation Layer (Flutter UI)             │
│  2. State Management Layer (setState/Provider)  │
│  3. Service Layer (Dart + Node.js logic)        │
│  4. Data Layer (Local JSON, SharedPreferences)  │
│  5. Firebase Cloud Layer (Auth, Firestore)      │
│                                                 │
│  See: Prime Diagrams/03_System_Architecture.md  │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The architecture follows a five-layer design. The Presentation Layer contains all Flutter UI screens. The State Management Layer handles reactive state changes. The Service Layer encapsulates business logic including session management, attendance processing, face recognition, and report generation. The Data Layer manages local persistence through JSON files and SharedPreferences. The Firebase Cloud Layer provides authentication, cloud database, and file storage.

---

### 8.4 Use Case Diagram

**Figure 4.4: Use Case Diagram**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│         [INSERT USE CASE DIAGRAM HERE]          │
│                                                 │
│  Lecturer Use Cases:                            │
│  • Login                                        │
│  • Create Session                               │
│  • Generate QR Code                             │
│  • Generate PIN                                 │
│  • Monitor Attendance                           │
│  • Export Reports                               │
│  • Sync to Firebase                             │
│                                                 │
│  Student Use Cases:                             │
│  • Connect to Hotspot                           │
│  • Scan QR Code                                 │
│  • Enter PIN                                    │
│  • Register Attendance                          │
│  • Submit Details                               │
│                                                 │
│  See: Prime Diagrams/04_Use_Case_Diagram.md     │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The use case diagram identifies two primary actors (Lecturer and Student) and two secondary actors (Node.js Server and Firebase Cloud). The Lecturer has seven use cases centered around session management and reporting. The Student has five use cases focused on the registration workflow. Key relationships include: Create Session <<includes>> Generate PIN and Generate QR Code; Register Attendance <<includes>> Enter PIN and Submit Face Image.

---

### 8.5 Activity Diagram

**Figure 4.5: Attendance Registration Activity Diagram**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│        [INSERT ACTIVITY DIAGRAM HERE]           │
│                                                 │
│  Flow:                                          │
│  Start → Create Session → Generate QR/PIN →     │
│  Student Connects → Registration Form Opens →   │
│  Student Submits Data → Face Verification →     │
│  Attendance Recorded → Dashboard Updated → End  │
│                                                 │
│  Swimlanes:                                     │
│  • Lecturer                                     │
│  • OwHAS Flutter App                            │
│  • Node.js Server                               │
│  • Student                                      │
│                                                 │
│  See: Prime Diagrams/05_Activity_Diagram.md     │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The activity diagram models the complete attendance workflow using four swimlanes. The Lecturer lane covers session creation and monitoring. The Student lane covers connection, form filling, and face capture. The Server lane covers PIN validation, face verification, and record storage. The App lane covers dashboard updates. Key decision points include PIN validation, face detection, and duplicate detection.

---

### 8.6 QR Code Attendance Flowchart

**Figure 4.6: QR Check-In Flowchart**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│      [INSERT QR CODE FLOWCHART HERE]            │
│                                                 │
│  Flow:                                          │
│  Generate QR → Student Scans → Browser Opens →  │
│  Registration Form Loads → Student Fills Form → │
│  Submit → Server Validates → Save Attendance    │
│                                                 │
│  See: Prime Diagrams/06_QR_Code_Flowchart.md    │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The QR flowchart shows the alternative registration path where students scan a displayed QR code instead of relying on captive portal auto-detection. The QR code encodes the server IP address and session PIN. When scanned, the student's browser opens directly to the registration page with the PIN pre-filled. This path is useful when captive portal detection fails on certain devices.

---

### 8.7 Captive Portal Flowchart

**Figure 4.7: Captive Portal Workflow**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│     [INSERT CAPTIVE PORTAL FLOWCHART HERE]      │
│                                                 │
│  Flow:                                          │
│  Connect to Hotspot → OS Detects No Internet →  │
│  Captive Portal Triggered → Registration Page   │
│  Opens Automatically → Student Registers →      │
│  Attendance Saved                               │
│                                                 │
│  See: Prime Diagrams/07_Captive_Portal.md       │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The captive portal workflow leverages the device operating system's built-in connectivity check. When a student connects to the lecturer's hotspot, the OS detects no internet and triggers a captive portal notification or auto-redirect. This opens the registration page automatically without the student needing to scan a QR code or type a URL. The diagram shows the flow for Android, iOS, and Windows devices.

---

### 8.8 Sequence Diagram

**Figure 4.8: Attendance Registration Sequence Diagram**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│       [INSERT SEQUENCE DIAGRAM HERE]            │
│                                                 │
│  Participants:                                  │
│  • Student Device                               │
│  • Captive Portal (hotspot.html)                │
│  • Node.js Server                               │
│  • Flutter Application                          │
│  • Database                                     │
│                                                 │
│  Messages: HTTP GET, POST /api/register,        │
│  face verification, save record, WebSocket      │
│  notification, confirmation response            │
│                                                 │
│  See: Prime Diagrams/08_Sequence_Diagram.md     │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The sequence diagram shows the time-ordered message flow between five participants during a student registration. The student's browser sends an HTTP request to the server. The server validates the PIN, processes the face image through face-api.js, checks for duplicates, and stores the record. It then notifies the Flutter app via WebSocket to update the dashboard. The diagram includes alt fragments for PIN validation (valid/invalid) and face verification (match/no match).

---

### 8.9 Component Diagram

**Figure 4.9: Component Diagram**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│       [INSERT COMPONENT DIAGRAM HERE]           │
│                                                 │
│  Components:                                    │
│  • UI Module (Flutter pages)                    │
│  • Session Module (session lifecycle)           │
│  • QR Module (QR generation/scanning)           │
│  • Attendance Module (registration logic)       │
│  • Face Recognition Module (face-api.js)        │
│  • Export Module (PDF/Excel generation)          │
│  • Firebase Module (cloud integration)          │
│  • Storage Module (local persistence)           │
│                                                 │
│  See: Prime Diagrams/09_Component_Diagram.md    │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The component diagram shows eight software modules and their dependency relationships. The UI Module depends on Session, Attendance, Export, Firebase, and QR modules. The Attendance Module depends on Face Recognition and Storage modules. The Export Module depends on Session, Attendance, and Storage. All modules that persist data depend on the Storage Module. Each component exposes provided interfaces and declares required interfaces.

---

### 8.10 Class Diagram

**Figure 4.10: Class Diagram**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│         [INSERT CLASS DIAGRAM HERE]             │
│                                                 │
│  Domain Classes:                                │
│  • User (abstract), Lecturer, Student           │
│  • AttendanceSession, AttendanceRecord           │
│                                                 │
│  Service Classes:                               │
│  • SessionService, AttendanceService            │
│  • StorageService, CloudService                 │
│                                                 │
│  Relationships:                                 │
│  • Lecturer inherits User                       │
│  • Lecturer creates Session (1:N)               │
│  • Session contains Records (composition, 1:N)  │
│  • Student has Records (1:N)                    │
│                                                 │
│  See: Prime Diagrams/10_Class_Diagram.md        │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The class diagram shows the object-oriented structure with domain classes (User, Lecturer, Student, AttendanceSession, AttendanceRecord) and service classes (SessionService, AttendanceService, StorageService, CloudService). Key relationships include inheritance (Lecturer extends User), composition (Session contains AttendanceRecords), and associations with multiplicity labels. Each class lists its attributes with types and visibility modifiers, and its key methods.

---

### 8.11 Entity Relationship Diagram (ERD)

**Figure 4.11: Entity Relationship Diagram**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│           [INSERT ERD DIAGRAM HERE]             │
│                                                 │
│  Entities:                                      │
│  • Lecturer (PK: lecturer_id)                   │
│  • Session (PK: session_id, FK: lecturer_id)    │
│  • AttendanceRecord (PK: record_id,             │
│    FK: session_id)                              │
│  • Student (PK: matric_number)                  │
│                                                 │
│  Relationships:                                 │
│  • Lecturer creates Session (1:N)               │
│  • Session contains AttendanceRecord (1:N)      │
│  • Student participates in Session (M:N via     │
│    AttendanceRecord)                            │
│                                                 │
│  See: Prime Diagrams/11_ERD_Diagram.md          │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The ERD shows four entities and their relationships using Crow's Foot notation. The Lecturer entity has a one-to-many relationship with Session. Session has a one-to-many relationship with AttendanceRecord. Student has a one-to-many relationship with AttendanceRecord. The many-to-many relationship between Student and Session is resolved through the AttendanceRecord junction table. Each entity lists its attributes with data types, primary keys, and foreign keys.

---

### 8.12 Deployment Diagram

**Figure 4.12: Deployment Diagram**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│       [INSERT DEPLOYMENT DIAGRAM HERE]          │
│                                                 │
│  Nodes:                                         │
│  • Lecturer Phone/Laptop                        │
│    └─ Flutter App, Local DB                     │
│  • Lecturer Device (Server Host)                │
│    └─ Node.js, Express, face-api.js             │
│  • Student Devices                              │
│    └─ Web Browser only                          │
│  • Firebase Cloud                               │
│    └─ Auth, Firestore, Storage                  │
│  • AWS EC2 (online mode)                        │
│    └─ Nginx, Node.js, SSL                       │
│                                                 │
│  See: Prime Diagrams/12_Deployment_Diagram.md   │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The deployment diagram maps software artifacts to physical and virtual nodes. In offline mode, the Flutter app and Node.js server both run on the lecturer's device. Student devices run only a web browser. In online mode, the Node.js server runs on an AWS EC2 instance behind Nginx. Firebase Cloud hosts authentication, Firestore database, and file storage. Communication paths show HTTP (port 8080) for local and HTTPS (port 443) for cloud connections.

---

### 8.13 Offline-First Synchronization Diagram

**Figure 4.13: Offline-First Synchronization Diagram**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│     [INSERT SYNC DIAGRAM HERE]                  │
│                                                 │
│  Flow:                                          │
│  Flutter App → Local Storage (always first) →   │
│  Connectivity Check →                           │
│    → Online: Firebase Sync                      │
│    → Offline: Queue for Later                   │
│                                                 │
│  See: Prime Diagrams/13_Offline_Sync_Diagram.md │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The synchronization diagram illustrates OwHAS's offline-first design principle. All data is written to local storage first, regardless of internet availability. A connectivity check then determines whether to sync immediately to Firebase (online) or queue for later sync (offline). The diagram shows sync states (PENDING, SYNCING, SYNCED, FAILED) and error handling with retry logic. This ensures zero data loss even in environments with no connectivity.

---

### 8.14 Device Fingerprinting Diagram

**Figure 4.14: Device Fingerprinting Process**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│    [INSERT DEVICE FINGERPRINTING DIAGRAM HERE]  │
│                                                 │
│  Flow:                                          │
│  Student Device → Collect Device Info →          │
│  Generate Fingerprint Hash → Duplicate Check →  │
│    → New device: Approve                        │
│    → Existing device: Flag/Reject               │
│                                                 │
│  See: Prime Diagrams/14_Device_Fingerprinting.md│
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The device fingerprinting diagram shows the fraud prevention mechanism. When a student submits attendance, JavaScript in the browser collects device attributes (User-Agent, screen resolution, canvas fingerprint, WebGL renderer, IP address). These are hashed into a unique fingerprint. The server compares this fingerprint against existing records for the session. New devices are approved; existing devices with different student names are flagged as suspicious. This works alongside face recognition and PIN validation as a layered security approach.

---

### 8.15 Firebase Integration Diagram

**Figure 4.15: Firebase Integration Architecture**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│    [INSERT FIREBASE INTEGRATION DIAGRAM HERE]   │
│                                                 │
│  Firebase Services:                             │
│  • Firebase Authentication (email/password)     │
│  • Cloud Firestore (sessions, records)          │
│  • Firebase Storage (PDF, Excel, face images)   │
│                                                 │
│  Flutter Integration:                           │
│  • AuthService ↔ Firebase Auth                  │
│  • SessionService ↔ Firestore                   │
│  • ReportService ↔ Firebase Storage             │
│                                                 │
│  See: Prime Diagrams/15_Firebase_Integration.md │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Description:**
The Firebase integration diagram shows how the Flutter application connects to three Firebase services. Firebase Authentication handles lecturer login with email/password. Cloud Firestore stores session documents with nested attendance record sub-collections. Firebase Storage holds exported report files (PDF/Excel). The Flutter app communicates with Firebase through the official Firebase SDK over HTTPS. Security rules ensure lecturers can only access their own data.

---

## 9. System Implementation

### 9.1 Development Environment Setup

**[INSERT: Development environment details]**

### 9.2 Project Structure

```
owhasfinal/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── pages/
│   │   ├── login_page.dart          # Firebase authentication
│   │   ├── session_page.dart        # Session creation
│   │   ├── dashboard_page.dart      # Live attendance monitoring
│   │   ├── report_page.dart         # Report generation
│   │   └── settings_page.dart       # App settings
│   ├── services/
│   │   ├── api_service.dart         # HTTP communication
│   │   ├── auth_service.dart        # Firebase auth
│   │   ├── session_service.dart     # Session management
│   │   ├── server_config.dart       # Server auto-detection
│   │   └── cloud_sync_service.dart  # Firebase sync
│   ├── models/
│   │   ├── session_model.dart       # Session data model
│   │   └── attendance_model.dart    # Attendance data model
│   └── widgets/                     # Reusable UI components
├── backend/
│   ├── server.js                    # Node.js Express server
│   ├── public/
│   │   ├── hotspot.html             # Captive portal page
│   │   └── models/                  # face-api.js neural networks
│   └── package.json                 # Node.js dependencies
├── android/                         # Android platform files
├── ios/                             # iOS platform files
├── web/                             # Web platform files
└── pubspec.yaml                     # Flutter dependencies
```

### 9.3 Key Implementation Details

#### 9.3.1 Server Auto-Detection

**[INSERT: How the app discovers and connects to the local or cloud server]**

#### 9.3.2 Face Recognition Pipeline

**[INSERT: How face-api.js processes face images]**

- Models used: SSD MobileNet v1, Face Landmark 68, Face Recognition Net, Face Expression Net, Age Gender Net
- Threshold: 0.45 Euclidean distance for duplicate detection
- Process: Detect → Extract 128-dim descriptor → Compare → Accept/Flag

#### 9.3.3 Captive Portal Implementation

**[INSERT: How the captive portal auto-redirect works]**

#### 9.3.4 Report Generation

**[INSERT: How PDF and Excel reports are generated]**

### 9.4 Key Code Snippets

**[INSERT: Selected code snippets with explanations for critical functionality]**

### 9.5 User Interface Screenshots

**[INSERT: Screenshots of key application screens]**

| Screen | Description |
|--------|-------------|
| Login Screen | Firebase email/password authentication |
| Session Creation | Course selection, PIN, duration, geofence config |
| QR Display | QR code shown for student scanning |
| Live Dashboard | Real-time attendee list and statistics |
| Report Screen | PDF/Excel generation and export |
| Student Registration | Web form with face capture and signature |

---

## 10. Testing & Validation

### 10.1 Testing Strategy

**[INSERT: Testing approach — unit, integration, system, UAT]**

### 10.2 Test Scenarios

**Table 6: Test Scenarios & Results**

| # | Test Scenario | Precondition | Steps | Expected Result | Actual Result | Status |
|---|--------------|--------------|-------|-----------------|---------------|--------|
| 1 | Offline session creation | Server running, hotspot active | Create session, start server | Session created with PIN | | |
| 2 | Student registration (offline) | Connected to hotspot | Enter PIN, fill form, submit | Attendance recorded | | |
| 3 | Face duplicate detection | One student already registered | Register with same face | Flagged as duplicate | | |
| 4 | PIN validation | Active session | Enter wrong PIN | Error message shown | | |
| 5 | Report generation (PDF) | Session ended with students | Generate PDF report | PDF file created | | |
| 6 | Report generation (Excel) | Session ended with students | Generate Excel report | Excel file created | | |
| 7 | Cloud sync | Internet available | Sync session to Firebase | Data uploaded successfully | | |
| 8 | GPS geofencing (online) | GPS enabled, geofence set | Register from outside fence | Location warning shown | | |
| 9 | Captive portal auto-redirect | Connected to hotspot | Open any URL | Redirected to registration | | |
| 10 | Concurrent registrations | 10+ students on hotspot | All submit simultaneously | All recorded without error | | |

### 10.3 Performance Benchmarks

**Table 8: Performance Benchmarks**

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Face recognition time | < 2 seconds | | |
| PIN validation time | < 500ms | | |
| Registration submission | < 1 second | | |
| Report generation (50 students) | < 5 seconds | | |
| Cloud sync time | < 10 seconds | | |
| Max concurrent connections (hotspot) | 50+ | | |

---

## 11. Results & Discussion

### 11.1 System Demonstration

**[INSERT: Description of system demonstration and results]**

### 11.2 Achievement of Objectives

| Objective | Status | Evidence |
|-----------|--------|----------|
| Offline attendance capture | | |
| Anti-proxy face recognition | | |
| Automated report generation | | |
| Cloud synchronization | | |
| Multiple deployment modes | | |

### 11.3 Discussion

**[INSERT: Analysis of results, comparison with objectives, strengths and weaknesses]**

---

## 12. Deployment

### 12.1 Deployment Options

**Table 7: Deployment Options Comparison**

| Aspect | Offline (Hotspot) | Online (Cloud) | Institutional (VLAN) |
|--------|-------------------|----------------|----------------------|
| Internet Required | No | Yes | Partial |
| Server Location | Lecturer's device | AWS EC2 | School server (ICTU) |
| Database | Local JSON | Firestore | Institutional DB |
| Scalability | ~50 students | 200+ students | Department-level |
| Setup Complexity | Simple (start app) | Moderate | Complex |
| URL | 192.168.x.1:8080 | owhas.org | atd.ictu.loc |
| Real-time Sync | No | Yes | Yes |

### 12.2 Installation Guide

**[INSERT: Step-by-step installation and setup instructions]**

### 12.3 Configuration

**[INSERT: Configuration parameters and environment variables]**

---

## 13. Limitations & Challenges

### 13.1 Technical Limitations

**[INSERT: Technical limitations encountered]**

1. **Face Recognition Accuracy:** Affected by lighting conditions, sunglasses, and masks
2. **Hotspot Range:** Limited to ~10-30 meters (classroom size)
3. **Concurrent Connections:** Hotspot mode limited to ~50 devices
4. **GPS Indoor Accuracy:** GPS unreliable indoors; geofencing only works in online mode
5. **Browser Compatibility:** Some older browsers may not support camera API

### 13.2 Challenges Encountered

**[INSERT: Development challenges and how they were addressed]**

### 13.3 Ethical Considerations

**[INSERT: Privacy concerns with face data, device fingerprinting, location tracking]**

---

## 14. Future Work

**[INSERT: Planned enhancements and extensions]**

1. Multi-lecturer support per hotspot
2. Student-side mobile application
3. Integration with institutional Student Information Systems (SIS)
4. Machine learning-based attendance prediction
5. Biometric fingerprint support
6. Video verification for high-security courses
7. Analytics dashboard for administrators
8. Mobile-to-mobile hotspot support (no laptop needed)

---

## 15. Conclusion

**[INSERT: Summary of achievements, contribution, and final remarks]**

---

## 16. References

**[INSERT: Academic references in APA/IEEE format]**

1. [Reference 1]
2. [Reference 2]
3. [Reference 3]
...

---

## 17. Appendices

### Appendix A: Complete API Documentation

**Table 5: API Endpoints**

| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|-------------|----------|
| POST | /api/session/start | Create new session | {course, pin, duration} | {sessionId, status} |
| POST | /api/session/end | End active session | {sessionId} | {status, count} |
| GET | /api/session/:id | Get session details | — | {session object} |
| POST | /api/attendance/register | Register student | {name, matric, pin, face} | {status, message} |
| GET | /api/attendance/:sessionId | Get attendee list | — | [{records}] |
| POST | /api/face/verify | Verify face | {image, sessionId} | {match, confidence} |
| GET | /api/report/:sessionId | Generate report | — | {pdf_url, excel_url} |

### Appendix B: Database Schema

**[INSERT: Complete database schema for all entities]**

### Appendix C: Source Code (Selected)

**[INSERT: Key source code files with annotations]**

### Appendix D: User Manual

**[INSERT: Step-by-step user guide for lecturers and students]**

### Appendix E: Glossary

| Term | Definition |
|------|-----------|
| Hotspot | Wi-Fi access point created by the lecturer's device |
| Geofence | Virtual geographic boundary for location verification |
| Face Descriptor | 128-dimensional vector representing unique facial features |
| Device Fingerprint | Unique identifier generated from device hardware/software attributes |
| Captive Portal | Web page automatically displayed when connecting to a Wi-Fi network |
| PIN | 4-digit Personal Identification Number for session access |
| Proxy Attendance | Fraudulent attendance where one person signs in for another |
| Firestore | Google Cloud's NoSQL document database |
| face-api.js | JavaScript library for face detection and recognition |

### Appendix F: Plagiarism Declaration

**[INSERT: Signed declaration of originality]**

---

**Document Status:** [ ] DRAFT  [ ] IN PROGRESS  [ ] COMPLETED

**Word Count:** [INSERT]

**Last Updated:** [INSERT DATE]

---

*End of Document*
