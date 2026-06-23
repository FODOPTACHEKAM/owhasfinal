# Diagram 06: Session State Machine

## Purpose
Show all possible states of an attendance session and the transitions between them.

## Type
**State Diagram / State Machine Diagram**

## States

### 1. NOT_STARTED
**Description:** Session has been configured but not yet initiated
**Characteristics:**
- Configuration complete
- No students registered
- No PIN generated yet
- Waiting for lecturer to start

**Entry Actions:**
- Lecturer clicks "Start Session"

**Exit Conditions:**
- All configuration complete

### 2. ACTIVE
**Description:** Session is currently running and accepting student registrations
**Characteristics:**
- PIN is valid and broadcasted
- Students can register
- Live dashboard is updating
- Server is accepting requests

**Activities:**
- Accept PIN submissions
- Process face registrations
- Update attendee list
- Calculate real-time statistics

**Exit Conditions:**
- Lecturer ends session OR timeout

### 3. PAUSED
**Description:** Session is temporarily suspended (optional state)
**Characteristics:**
- No new registrations accepted
- Existing data preserved
- Can be resumed

**Entry Actions:**
- Pause icon clicked

**Exit Conditions:**
- Resume clicked OR End session

### 4. ENDED
**Description:** Session is closed, no more registrations accepted
**Characteristics:**
- Final attendee count recorded
- Session marked as complete
- Report generation initiated
- Data locked

**Entry Actions:**
- Lecturer clicks "End Session"

**Exit Conditions:**
- Automatic transition to EXPORTED after timeout

### 5. EXPORTED
**Description:** Report has been generated and exported locally
**Characteristics:**
- PDF and Excel files created
- Local file storage complete
- Ready for cloud sync or manual backup

**Activities:**
- Generate PDF report
- Generate Excel report
- Save to device storage
- Create checksums for verification

**Exit Conditions:**
- Upload to cloud OR manual backup complete

### 6. SYNCED
**Description:** Session data has been uploaded to Firebase cloud
**Characteristics:**
- Data replicated to cloud
- Backup secured
- Can be accessed from any device
- Archive complete

**Entry Actions:**
- Cloud sync initiated

**Exit Conditions:**
- Final state (stable)

## Transitions

### NOT_STARTED → ACTIVE
**Trigger:** `startSession()`
**Condition:** All configuration valid, PIN generated
**Action:** Broadcast PIN and QR code
**Guard:** `isConfigurationValid() && serverRunning()`

### ACTIVE → PAUSED
**Trigger:** `pauseSession()`
**Condition:** Lecturer clicks pause
**Action:** Disable registration temporarily
**Guard:** `isLecturerAction()`

### PAUSED → ACTIVE
**Trigger:** `resumeSession()`
**Condition:** Lecturer clicks resume
**Action:** Re-enable registration
**Guard:** `isLecturerAction()`

### ACTIVE → ENDED
**Trigger:** `endSession()`
**Condition:** Lecturer clicks end OR timeout reached
**Action:** Lock registration, finalize data
**Guard:** `timeElapsed() >= sessionDuration || lecturerAction()`

### PAUSED → ENDED
**Trigger:** `endSession()`
**Condition:** Lecturer ends from paused state
**Action:** Lock registration, finalize data
**Guard:** `isLecturerAction()`

### ENDED → EXPORTED
**Trigger:** `generateReport()`
**Condition:** Report generation successful
**Action:** Create PDF/Excel files
**Guard:** `attendeeListPopulated()`

### EXPORTED → SYNCED
**Trigger:** `syncToCloud()`
**Condition:** Internet available, cloud credentials valid
**Action:** Upload to Firebase
**Guard:** `internetAvailable() && firebaseAuthenticated()`

### ACTIVE → ACTIVE (Self-loop)
**Trigger:** `updateDashboard()`
**Condition:** Continuously throughout session
**Action:** Refresh attendee list, update counts
**Guard:** Always (auto-repeating)

## Error States (Optional)

### ACTIVE → ERROR
**Trigger:** Server crash, database error, network loss
**Action:** Log error, attempt recovery
**Recovery:** Retry server connection

### ERROR → ACTIVE
**Trigger:** `retryConnection()`
**Condition:** System recovered
**Action:** Resume normal operation

## State Transition Table

| From State | To State | Trigger | Condition | Action |
|------------|----------|---------|-----------|--------|
| NOT_STARTED | ACTIVE | startSession() | config valid | broadcast PIN |
| ACTIVE | PAUSED | pauseSession() | lecturer action | disable reg |
| PAUSED | ACTIVE | resumeSession() | lecturer action | enable reg |
| ACTIVE | ENDED | endSession() | time/action | lock reg |
| PAUSED | ENDED | endSession() | lecturer action | lock reg |
| ENDED | EXPORTED | generateReport() | success | create files |
| EXPORTED | SYNCED | syncToCloud() | internet + auth | upload data |
| ACTIVE | ERROR | exception | system error | log + retry |
| ERROR | ACTIVE | retry() | system recovered | resume |

## Key Information to Display
- State names (circles/rounded rectangles)
- Transitions (arrows with labels)
- Triggers (action that causes transition)
- Conditions (guards in brackets)
- Actions (on arrow label)
- Current state indicator (highlighted)
- Initial state marker (arrow pointing in)
- Final state marker (double circle)

## Visual Elements
- States as rounded rectangles or circles
- Transitions as labeled arrows
- Guard conditions in square brackets [condition]
- Entry/exit actions labeled
- Self-loops for internal activities
- Color coding: Active (green), Paused (yellow), Ended (red)

## Success Criteria
- All states clearly labeled
- All transitions shown
- Triggers and conditions visible
- Guards are clear and logical
- No impossible transitions
- Covers normal and error scenarios
- Easy to follow the workflow

## Tools Suitable For
- Draw.io
- Lucidchart
- Enterprise Architect
- Visual Paradigm
- PlantUML

## Related Sections in Final_Doc
- Section 4.3: State Machine Diagram
- Section 6: User Workflows
