# Diagram 01: Overall System Architecture

## Purpose
Provide a high-level overview of the entire OWHAS system showing all major components and their relationships.

## Type
**Architecture Diagram** (Box and Arrow / Component Diagram)

## Components to Include

### Main Boxes
1. **Flutter Mobile Application** (Lecturer side)
   - Main app interface
   - Session management
   - Dashboard
   - Report generation

2. **Node.js Backend Server** (Local/Cloud)
   - Express API
   - Business logic
   - Database connection
   - Session management

3. **Web Portal** (Student side)
   - hotspot.html
   - Registration interface
   - Face capture module
   - GPS verification

4. **Face-API.js** (Client-side)
   - Face detection models
   - Descriptor extraction
   - Duplicate detection

5. **Firebase Cloud Services**
   - Authentication (Firebase Auth)
   - Firestore Database
   - Cloud Storage
   - Cloud Functions

6. **Local Database**
   - SQLite / JSON
   - Session data
   - Attendance records

7. **External Services**
   - Google Maps API (GPS)
   - WiFi Hotspot
   - Certificate Authority (SSL/TLS)

### Connections to Show
- Flutter App ↔ Node.js Server (HTTPS/REST)
- Web Browser ↔ Node.js Server (HTTP/HTTPS)
- Node.js ↔ Firebase (SDK connection)
- Web Browser ↔ Face-API.js (JavaScript)
- Node.js ↔ Local Database (SQL/File I/O)
- Mobile App ↔ Google Maps API (GPS queries)
- Node.js ↔ Firebase Storage (File uploads)

### Data Flow Annotations
- Show direction of data flow with arrows
- Label connection types (REST API, WebSocket, Direct DB, etc.)
- Indicate which flows are encrypted

## Key Information to Display
- Component names
- Technology stack per component
- Data flow direction
- Connection protocols
- Optional: Color coding by layer (UI, Business Logic, Data, External)

## Success Criteria
- All major components visible and labeled
- Clear data flow paths
- Shows both offline and online paths
- Easy to understand at a glance

## Tools Suitable For
- Draw.io / Lucidchart
- Mermaid (graph syntax)
- OmniGraffle
- Visio

## Related Sections in Final_Doc
- Section 3.1: High-Level System Architecture
- Section 9: Deployment Architecture
