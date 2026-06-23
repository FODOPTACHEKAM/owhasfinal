# Figure 4.13: Offline-First Synchronization Diagram

## Purpose
Shows the local storage and cloud synchronization mechanism in OwHAS.

## Diagram Type
**Data Flow / Synchronization Diagram**

## Concept: Offline-First Architecture
OwHAS is designed to work without internet. All data is first saved locally on the lecturer's device. When internet becomes available, data is synchronized to Firebase Cloud for backup and cross-device access. This ensures zero data loss even in environments with no connectivity.

## Synchronization Flow

### Step 1: Flutter App (Data Source)
- **Actions:**
  - Lecturer creates sessions
  - Students register attendance
  - Reports are generated
- **Output:** Raw data objects (sessions, records, files)

### Step 2: Local Storage (Primary)
- **Technology:** JSON files + SharedPreferences + Device file system
- **Data Stored:**
  - Session configurations (JSON)
  - Attendance records (JSON)
  - Face descriptors (JSON arrays)
  - Generated reports (PDF/Excel files)
  - App settings and preferences
- **Behavior:** Data is written here FIRST, regardless of internet status
- **Location:** App-specific directory on device storage

### Step 3: Connectivity Check
- **Technology:** Dart connectivity_plus package
- **Check:** Is the device connected to the internet?
- **Triggers:**
  - App startup
  - User manually initiates sync
  - Network state change detected
  - Session end (auto-sync attempt)

### Step 4: Firebase Sync (Secondary)
- **Technology:** Firebase SDK (Firestore + Storage)
- **Sync Operations:**
  - Upload session data → Firestore collection
  - Upload attendance records → Firestore sub-collection
  - Upload report files → Firebase Storage
  - Download updated data (if modified from another device)
- **Conflict Resolution:** Last-write-wins (timestamp-based)

## Synchronization Flow Diagram
```
+------------------+
| Flutter App      |
| (Data Created)   |
+--------+---------+
         |
         v
+------------------+
| Local Storage    |
| (Always Saved)   |
| - JSON files     |
| - PDF/Excel      |
| - Preferences    |
+--------+---------+
         |
         v
+------------------+
| Connectivity     |
| Check            |
+--------+---------+
         |
    +----+----+
    |         |
    v         v
  [Online]  [Offline]
    |         |
    v         v
+----------+ +---------------+
| Firebase | | Queue for     |
| Sync     | | Later Sync    |
| - Upload | | - Mark pending|
| - Confirm| | - Retry later |
+----------+ +---------------+
    |              |
    v              v
+------------------+
| Sync Complete    |
| or Queued        |
+------------------+
```

## Sync States

| State | Description | Action |
|-------|-------------|--------|
| PENDING | Data saved locally, not yet synced | Waiting for connectivity |
| SYNCING | Upload in progress | Transferring to Firebase |
| SYNCED | Successfully uploaded to cloud | Mark as backed up |
| FAILED | Sync attempt failed | Retry on next connectivity check |
| CONFLICT | Local and cloud versions differ | Resolve using timestamp |

## Data Types and Sync Priority

| Data Type | Priority | Size | Sync Method |
|-----------|----------|------|-------------|
| Session metadata | High | Small | Firestore document |
| Attendance records | High | Medium | Firestore sub-collection |
| Face descriptors | Medium | Small | Embedded in attendance record |
| PDF reports | Low | Large | Firebase Storage |
| Excel reports | Low | Medium | Firebase Storage |
| App settings | Lowest | Tiny | Not synced (local only) |

## Error Handling

| Error | Cause | Recovery |
|-------|-------|----------|
| No internet | Wi-Fi/cellular unavailable | Queue and retry later |
| Firebase auth expired | Token timeout | Re-authenticate silently |
| Upload timeout | Slow connection | Retry with exponential backoff |
| Storage quota exceeded | Firebase free tier limit | Warn user, prioritize essential data |
| Partial sync | Connection lost mid-upload | Resume from last successful record |

## Drawing Instructions
1. Show Flutter App at the top as the data source
2. Local Storage in the middle as the primary persistence layer
3. Connectivity check as a decision diamond
4. Firebase Cloud at the bottom for successful sync
5. Pending queue for offline scenarios
6. Use arrows showing data flow direction
7. Color code: Green (synced), Yellow (pending), Red (failed)

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
