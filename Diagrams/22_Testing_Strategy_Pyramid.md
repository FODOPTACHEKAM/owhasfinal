# Diagram 22: Testing Strategy Pyramid

## Purpose
Show the testing strategy and levels of testing for OWHAS system.

## Type
**Testing Pyramid Diagram / Test Strategy Diagram**

## Test Pyramid Levels

```
                        △
                       /|\
                      / | \
                     /  |  \
                    / UI Tests \        (10%)
                   /  (System)   \
                  /_______________\
                 /|\             /|\
                /   \           /   \
               / Integration \  / Integration \
              /   Tests        \/   Tests      \   (20%)
             /__________________\_______________\
            /|\                                /|\
           / | \                              / | \
          /  |  \                            /  |  \
         / Unit Tests (Functions, Classes)  /  |  \
        /________________\/___________________/   \    (70%)
        (Base Level - Most Tests)
```

## Level 1: Unit Tests (70% - Base)

### Purpose
Test individual functions, methods, and classes in isolation

### Areas Covered

**Backend Unit Tests (Node.js)**
```
1. PIN Validation Functions
   ├─ Test: isValidPIN("1234") → true
   ├─ Test: isValidPIN("00000") → false
   ├─ Test: isValidPIN("abc") → false
   ├─ Test: isValidPIN("") → false
   └─ Coverage: 100% of validation logic

2. Face Descriptor Comparison
   ├─ Test: calculateDistance([...], [...]) > 0.6
   ├─ Test: calculateDistance(descriptor, descriptor) ≈ 0
   ├─ Test: Euclidean distance accuracy
   └─ Coverage: 100% of distance calculation

3. GPS Distance Calculation
   ├─ Test: haversineDistance(33.8688, 73.1012, 33.8688, 73.1012) ≈ 0
   ├─ Test: haversineDistance(locations) ≈ known value
   ├─ Test: Boundary cases (equator, poles)
   └─ Coverage: 100% of geo calculations

4. Session State Transitions
   ├─ Test: NOT_STARTED → ACTIVE (valid)
   ├─ Test: ACTIVE → ENDED (valid)
   ├─ Test: ENDED → ENDED (invalid, error thrown)
   ├─ Test: All state combinations
   └─ Coverage: All transitions validated

5. Database Model Validations
   ├─ Test: Student.create({}) → error (missing fields)
   ├─ Test: Course.update(valid_data) → success
   ├─ Test: AttendanceRecord relationships
   └─ Coverage: Model constraints

6. Utility Functions
   ├─ Test: DateFormatting
   ├─ Test: PDFGeneration
   ├─ Test: Excel export
   ├─ Test: CSV parsing
   └─ Coverage: 100% of utility logic
```

**Frontend Unit Tests (Flutter/Dart)**
```
1. Face Detection Widget Tests
   ├─ Test: Widget initialization
   ├─ Test: Camera permission handling
   ├─ Test: Tap button interactions
   └─ Coverage: UI interactions

2. Form Validation
   ├─ Test: PIN input validation
   ├─ Test: Email format validation
   ├─ Test: Required field checks
   └─ Coverage: All form fields

3. State Management
   ├─ Test: Session state updates
   ├─ Test: Attendance record creation
   ├─ Test: Token management
   └─ Coverage: State transitions

4. Local Storage Operations
   ├─ Test: Save session data
   ├─ Test: Retrieve stored sessions
   ├─ Test: Clear cache
   └─ Coverage: Storage operations
```

### Test Tools
```
Backend:
  ├─ Jest (Facebook testing framework)
  ├─ Mocha + Chai (alternative)
  └─ Supertest (HTTP testing)

Frontend:
  ├─ Flutter test framework (built-in)
  ├─ Mockito (mocking library)
  └─ Test fixtures

Coverage Goal: 85%+ line coverage
```

## Level 2: Integration Tests (20%)

### Purpose
Test interactions between multiple components

### Test Scenarios

**API Integration Tests**
```
1. PIN Verification Flow
   ├─ Browser sends PIN → Express server
   ├─ Server queries SQLite
   ├─ Server returns token
   ├─ Browser stores token
   └─ Verify: Token valid for next request

2. Full Registration Flow
   ├─ Student enters PIN (Scenario 1)
   ├─ Student captures face (face-api.js runs)
   ├─ Face descriptor sent to server
   ├─ Server checks for duplicates
   ├─ Server creates AttendanceRecord in DB
   ├─ Browser receives confirmation
   └─ Verify: Record stored in database

3. Cloud Sync Flow
   ├─ Local app saves session
   ├─ Sync button clicked
   ├─ App connects to Firebase
   ├─ Data uploaded to Firestore
   ├─ Cloud Function processes data
   ├─ Report generated and stored
   ├─ App receives confirmation
   └─ Verify: Data present in cloud

4. Report Generation Integration
   ├─ Session ends
   ├─ Report service queries all records
   ├─ PDF generator creates document
   ├─ Excel exporter creates spreadsheet
   ├─ Files saved to filesystem
   └─ Verify: Both files created and readable
```

**Database Integration Tests**
```
1. Multi-table Transactions
   ├─ Create Session
   ├─ Add AttendanceRecords (multiple)
   ├─ Update Statistics
   ├─ Create Reports
   └─ Verify: Consistent state across tables

2. Concurrent Access
   ├─ Multiple students registering simultaneously
   ├─ Database maintains consistency
   ├─ No duplicate records created
   └─ Verify: Race conditions handled
```

**Authentication Integration**
```
1. Token Validation Across Requests
   ├─ Login → receive token
   ├─ Make API request with token
   ├─ Server validates token
   ├─ Request proceeds
   └─ Verify: Authorization working

2. Token Refresh
   ├─ Token nearing expiry
   ├─ App automatically refreshes
   ├─ New token issued
   ├─ Requests continue without interruption
   └─ Verify: Seamless refresh
```

### Test Tools
```
Backend:
  ├─ Jest (multiple test files)
  ├─ Supertest + SQLite test DB
  └─ Docker (test environment)

Frontend:
  ├─ Integration test frameworks
  ├─ Mock servers (for testing)
  └─ Device/emulator testing

Test Database: Separate SQLite instance (not production)
Fixtures: Pre-loaded test data
```

## Level 3: System/UI Tests (10% - Top)

### Purpose
End-to-end testing of complete workflows

### Test Scenarios

**Lecturer Workflow Test**
```
Test 1: Complete Session Workflow
  1. Open Flutter app
  2. Select course from list
  3. Configure session (PIN, duration, max students)
  4. Click "Start Session"
  5. See PIN and QR code displayed
  6. Monitor live dashboard as students register
  7. See attendee list update in real-time
  8. End session
  9. Generate PDF and Excel reports
  10. Download reports
  └─ Verify: Reports contain correct data

Test 2: Cloud Sync Workflow
  1. Sign in to Firebase
  2. Start online session
  3. Students register (both local + cloud)
  4. End session
  5. Sync to cloud button
  6. Wait for upload complete
  7. Verify data in cloud dashboard
  └─ Verify: Cloud has identical data
```

**Student Workflow Test**
```
Test 1: Complete Registration (Happy Path)
  1. Connect to hotspot
  2. Browser auto-opens registration
  3. Enter PIN
  4. Capture face
  5. (Optional) Provide signature
  6. Submit registration
  7. See confirmation
  └─ Verify: Student registered in session

Test 2: Error Handling
  1. Enter wrong PIN → Error message
  2. Get up, try again → Success
  3. Face not detected → Error + retry
  4. Outside geofence → Warning + refresh button
  └─ Verify: All errors handled gracefully

Test 3: Proxy Detection Test
  1. Student 1 registers
  2. Student 2 tries with similar face (spoofed)
  3. Duplicate detected alert shown
  4. Lecturer notified
  └─ Verify: Proxy attempt identified
```

**Cross-Device Test**
```
Test 1: Multiple Platforms
  ├─ Windows lecturer device + Android students
  ├─ Mac lecturer device + iOS students
  ├─ Ubuntu lecturer device + Web browser students
  └─ Verify: All combinations work

Test 2: Network Changes
  ├─ Start session on hotspot
  ├─ Enable mobile data (dual connectivity)
  ├─ Connection switches seamlessly
  └─ Verify: Session continues uninterrupted
```

### Test Tools
```
Framework: Selenium / Appium / Flutter driver
Devices:
  ├─ Real devices (iOS, Android)
  ├─ Emulators (faster, cost-effective)
  └─ Cloud testing services (Sauce Labs, BrowserStack)

Test Automation:
  ├─ Record & playback
  ├─ Scripted automation
  └─ CI/CD integration

Browser Testing:
  ├─ Chrome
  ├─ Safari
  ├─ Firefox
  └─ Edge
```

## Testing Infrastructure

### Continuous Integration (CI)
```
Trigger: Every code commit to GitHub

Pipeline:
  1. Unit tests (5 minutes)
  2. Integration tests (10 minutes)
  3. Code coverage report (1 minute)
  4. Build artifact (2 minutes)
  5. System tests (on cloud - 20 minutes)
  6. Report results
  └─ Total: ~40 minutes per commit

Failure Action:
  ├─ Halt deployment
  ├─ Notify developer
  ├─ Prevent merge
  └─ Require fix + re-test
```

### Test Data Management
```
Test Database:
  ├─ Size: ~100MB (sample data)
  ├─ Reset: Before each test run
  ├─ Fixtures: Pre-defined test scenarios
  └─ Seeding: Automated test data generation

Test Coverage Metrics:
  ├─ Line coverage: Target 85%+
  ├─ Branch coverage: Target 80%+
  ├─ Function coverage: Target 90%+
  └─ Statement coverage: Target 85%+
```

## Performance Testing

### Load Testing
```
Tool: Apache JMeter or Locust

Test Scenarios:
  1. 50 concurrent students registering
     └─ Measure: Response time, error rate
  2. 100 students registering simultaneously
     └─ Measure: System breaking point
  3. Live dashboard update (WebSocket)
     └─ Measure: Event delivery latency
  4. Report generation with 1000 records
     └─ Measure: Generation time

Acceptance Criteria:
  ├─ 50 concurrent: < 2 second response time
  ├─ 100 concurrent: < 5 second response time
  ├─ Live updates: < 100ms latency
  ├─ Report generation: < 10 seconds
  └─ Error rate: < 1%
```

### Stress Testing
```
Gradual load increase:
  ├─ Start: 10 concurrent users
  ├─ Increase: +10 every 2 minutes
  ├─ Continue: Until system failure
  ├─ Measure: Failure point and recovery
  └─ Target: System stable up to 200 concurrent
```

## Security Testing

### Penetration Testing
```
Areas:
  ├─ SQL Injection (test inputs)
  ├─ XSS (cross-site scripting)
  ├─ CSRF (cross-site request forgery)
  ├─ Authentication bypass attempts
  ├─ Authorization vulnerabilities
  ├─ Sensitive data exposure
  └─ API security

Tools:
  ├─ OWASP ZAP (automated)
  ├─ Burp Suite (manual testing)
  ├─ Kali Linux tools
  └─ Custom scripts
```

## Test Report Format

```
Test Summary:
  ├─ Total tests: 450
  ├─ Passed: 445 (98.9%)
  ├─ Failed: 5 (1.1%)
  ├─ Skipped: 0
  └─ Execution time: 45 minutes

Coverage Report:
  ├─ Line coverage: 87%
  ├─ Branch coverage: 82%
  └─ File-by-file breakdown

Failures:
  ├─ Test name
  ├─ Expected vs Actual
  ├─ Stack trace
  └─ Assigned to: Developer
```

## Success Criteria
- Test pyramid clearly shows distribution
- All three levels explained
- Test scenarios detailed
- Tools specified for each level
- CI/CD integration shown
- Performance benchmarks set
- Security testing included
- Test coverage goals defined
- Report format specified

## Tools Suitable For
- Draw.io (diagram)
- Lucidchart
- Miro/Mural
- Testing frameworks (Jest, Pytest, etc.)

## Related Sections in Final_Doc
- Section 10.1: Test Coverage Plan
- Section 10: Testing & Validation
