# Diagram 03: Component Interaction Diagram

## Purpose
Show how individual system components interact and communicate with each other in real-time.

## Type
**Component Interaction Diagram** (Box and Arrow / Communication Diagram)

## Components to Show

### Primary Components
1. **Mobile App** (Flutter)
   - Lecturer interface
   - Session management
   - Dashboard

2. **Local Node.js Server**
   - API endpoints
   - Session handler
   - Face verification handler

3. **Web Portal** (hotspot.html)
   - Student registration interface
   - Face-API.js integration

4. **Face-API.js**
   - Client-side face detection
   - Descriptor extraction

5. **Local Database**
   - Attendance records
   - Session configuration
   - Device fingerprints

6. **Firebase/Cloud**
   - Real-time database (Firestore)
   - Authentication
   - Cloud Functions

7. **Google Maps API**
   - GPS geolocation
   - Geofence validation

### Interactions to Show (with numbered sequence)

1. **Lecturer Creates Session**
   - Mobile App → Local Server: POST /api/session/start
   - Local Server → Local Database: Save session data
   - Local Server → Mobile App: Return PIN + QR

2. **Student Registration**
   - Web Portal (Browser) → Local Server: Enter PIN
   - Local Server → Face-API.js: Load face detection models
   - Face-API.js → Web Portal: Face captured
   - Web Portal → Local Server: Submit face descriptor
   - Local Server → Local Database: Store record
   - Local Server → Web Portal: Confirmation

3. **GPS Verification**
   - Web Portal → Google Maps API: Get GPS coordinates
   - Google Maps API → Web Portal: Return coordinates
   - Web Portal → Local Server: Send coordinates
   - Local Server → Local Database: Store location

4. **Cloud Sync**
   - Local Server → Firebase: Sync session data
   - Local Server → Firebase Storage: Upload reports
   - Firebase → Mobile App: Notify sync complete

### Interaction Types to Indicate
- Synchronous calls (solid arrows)
- Asynchronous calls (dashed arrows)
- Data flow direction (arrow direction)
- Protocol type (label: HTTP, WebSocket, Database query, etc.)
- Success/failure paths (if complex)

## Key Information to Display
- Component names
- Call/method names
- Direction of communication
- Response types
- Optional: sequence numbers
- Optional: timing information

## Success Criteria
- All components shown with clear interactions
- Flow is easy to follow
- Shows both success and error paths if applicable
- Indicates synchronous vs asynchronous operations
- All major API calls visible

## Tools Suitable For
- Draw.io
- Lucidchart
- Sequence diagram tools
- UML diagramming software

## Related Sections in Final_Doc
- Section 3.3: Component Interaction Flow
- Section 4: Component Diagrams
