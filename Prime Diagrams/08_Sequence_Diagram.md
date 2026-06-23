# Figure 4.8: Attendance Registration Sequence Diagram

## Purpose
Shows the time-ordered communication between system components during attendance registration.

## Diagram Type
**UML Sequence Diagram**

## Participants (Objects / Lifelines)

| # | Participant | Type | Description |
|---|-------------|------|-------------|
| 1 | Student Device | Actor/Browser | Student's phone or laptop browser |
| 2 | Captive Portal | Web Page | hotspot.html served by Node.js |
| 3 | Node.js Server | Backend | Express server on lecturer's device |
| 4 | Flutter Application | Mobile App | Lecturer's Flutter app |
| 5 | Database | Storage | Local JSON/SQLite storage |

## Message Sequence

### Phase 1: Connection
```
Student Device          Captive Portal       Node.js Server       Flutter App          Database
     |                       |                    |                    |                   |
     |-- Connect to Wi-Fi ---|------------------→ |                    |                   |
     |                       |                    |                    |                   |
     |← Captive Portal Redirect ------------------|                    |                   |
     |                       |                    |                    |                   |
     |-- HTTP GET /hotspot.html ----------------→ |                    |                   |
     |                       |                    |                    |                   |
     |← Return HTML page ---|---------------------|                    |                   |
```

### Phase 2: PIN Validation
```
     |                       |                    |                    |                   |
     |-- Enter PIN --------→ |                    |                    |                   |
     |                       |-- POST /api/       |                    |                   |
     |                       |   validate-pin --→ |                    |                   |
     |                       |                    |-- Query session    |                   |
     |                       |                    |   by PIN --------→ |                   |
     |                       |                    |                    |-- Read session -→ |
     |                       |                    |                    |                   |
     |                       |                    |                    |←- Session data ---|
     |                       |                    |←- Session found ---|                   |
     |                       |←- PIN valid -------|                    |                   |
     |←- Show form ---------|                    |                    |                   |
```

### Phase 3: Face Capture & Submission
```
     |                       |                    |                    |                   |
     |-- Capture face -----→ |                    |                    |                   |
     |   (camera API)        |                    |                    |                   |
     |                       |                    |                    |                   |
     |-- Submit form ------→ |                    |                    |                   |
     |   {name, matric,      |                    |                    |                   |
     |    PIN, faceImage,    |                    |                    |                   |
     |    signature}         |                    |                    |                   |
     |                       |-- POST /api/       |                    |                   |
     |                       |   register ------→ |                    |                   |
```

### Phase 4: Face Verification
```
     |                       |                    |                    |                   |
     |                       |                    |-- Load face-api    |                   |
     |                       |                    |   models           |                   |
     |                       |                    |                    |                   |
     |                       |                    |-- Detect face      |                   |
     |                       |                    |   in image         |                   |
     |                       |                    |                    |                   |
     |                       |                    |-- Extract 128-dim  |                   |
     |                       |                    |   descriptor       |                   |
     |                       |                    |                    |                   |
     |                       |                    |-- Compare with     |                   |
     |                       |                    |   existing         |                   |
     |                       |                    |   descriptors      |                   |
     |                       |                    |                    |                   |
     |                       |                    |-- [alt] No match:  |                   |
     |                       |                    |   Accept           |                   |
     |                       |                    |-- [alt] Match:     |                   |
     |                       |                    |   Flag duplicate   |                   |
```

### Phase 5: Record & Confirm
```
     |                       |                    |                    |                   |
     |                       |                    |-- Save record ---→ |                   |
     |                       |                    |                    |-- Write to DB --→ |
     |                       |                    |                    |←- Confirm --------|
     |                       |                    |←- Record saved ----|                   |
     |                       |                    |                    |                   |
     |                       |                    |-- Notify Flutter   |                   |
     |                       |                    |   app (WebSocket)→ |                   |
     |                       |                    |                    |-- Update          |
     |                       |                    |                    |   dashboard       |
     |                       |                    |                    |                   |
     |                       |←- 200 OK ---------|                    |                   |
     |←- Show confirmation --|                    |                    |                   |
     |                       |                    |                    |                   |
```

## Key Messages Summary

| # | From | To | Message | Type |
|---|------|----|---------|------|
| 1 | Student | Server | HTTP GET /hotspot.html | Synchronous |
| 2 | Server | Student | HTML registration page | Return |
| 3 | Student | Portal | Enter PIN | User action |
| 4 | Portal | Server | POST /api/validate-pin | Synchronous |
| 5 | Server | Database | Query session by PIN | Synchronous |
| 6 | Server | Portal | PIN validation result | Return |
| 7 | Student | Portal | Submit form (name, face, etc.) | User action |
| 8 | Portal | Server | POST /api/register | Synchronous |
| 9 | Server | Server | Face detection & verification | Self-call |
| 10 | Server | Database | Save attendance record | Synchronous |
| 11 | Server | Flutter App | WebSocket notification | Asynchronous |
| 12 | Server | Portal | 200 OK (confirmation) | Return |
| 13 | Portal | Student | Display confirmation | Return |

## Combined Fragments
- **alt** (PIN Valid / PIN Invalid): Branching after PIN validation
- **alt** (Face Match / No Match): Branching after face comparison
- **opt** (GPS Verification): Only in online mode
- **opt** (Digital Signature): Optional step

## Drawing Instructions
1. Place 5 participants across the top with lifelines descending
2. Messages flow left-to-right (requests) and right-to-left (responses)
3. Time flows top-to-bottom
4. Use solid arrows for synchronous calls, dashed for returns
5. Use activation bars on lifelines during processing
6. Add alt/opt fragments as rectangles around conditional messages

## Tools
- Draw.io / diagrams.net
- Lucidchart
- PlantUML
- Visual Paradigm
- Mermaid.js
