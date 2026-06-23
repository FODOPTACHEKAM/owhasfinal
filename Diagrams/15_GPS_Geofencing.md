# Diagram 15: GPS Verification & Geofencing Flow

## Purpose
Show how GPS location verification and geofencing works to prevent remote attendance spoofing in online mode.

## Type
**Process Flow Diagram with Decision Points**

## Overview

GPS geofencing is used to verify that students registering for attendance are physically present in the classroom (online/hybrid mode).

```
Course Lecturer (Online):
  ├─ Sets geofence center: {latitude, longitude}
  ├─ Sets geofence radius: e.g., 50 meters
  ├─ Student registers from mobile browser
  ├─ System requests GPS location
  ├─ Calculates distance to geofence center
  └─ Decision: Inside or outside classroom?
```

## Stage 1: Geofence Configuration (By Lecturer)

### Setup in Session Configuration
```
Lecturer (in Flutter app):
  |
  ├─→ Configure Session Form
  |       Field: "Enable Location Verification"
  |       Toggle: ON/OFF (default: ON for online sessions)
  |
  ├─→ Enter Classroom Location
  |       Method 1: Manual coordinates
  |         - Input: Latitude (e.g., 33.8688)
  |         - Input: Longitude (e.g., 73.1012)
  |
  |       Method 2: Current location (auto)
  |         - Click: "Use Current Location"
  |         - System acquires GPS from lecturer device
  |
  |       Method 3: Search map
  |         - Search for classroom/building
  |         - Drop pin on map
  |
  ├─→ Enter Geofence Radius
  |       Input: Radius in meters
  |       Typical: 50m, 75m, 100m, 150m
  |       (Depends on classroom size/campus)
  |
  ├─→ Confirmation
  |       Display map preview showing:
  |       - Geofence center (red pin)
  |       - Geofence circle (shaded area)
  |       - Radius in meters
  |
  └─ Geofence saved in Session settings
```

## Stage 2: Student GPS Location Request

### Obtaining GPS Location
```
Student: Registration in progress
  |
  ├─→ Browser: Display "Verifying Location"
  |
  ├─→ JavaScript: navigator.geolocation.getCurrentPosition()
  |
  ├─→ Mobile OS: GPS Permission Dialog
  |       User sees: "[App] wants to know your location"
  |       Options:
  |       ├─ Allow (Always / Only This Time)
  |       ├─ Don't Allow
  |       └─ (Varies by OS/version)
  |
  ├─→ User: Grants permission
  |
  ├─→ GPS Hardware: Acquire satellite signals
  |       Time to acquire (TTFF):
  |       - Cold start: 30-60 seconds
  |       - Warm start: 5-10 seconds
  |       - Hot start: < 1 second
  |       (Depends on GPS cache)
  |
  ├─→ GPS Module: Calculate position
  |       Data provided:
  |       - Latitude (degrees, decimal)
  |       - Longitude (degrees, decimal)
  |       - Altitude (meters, optional)
  |       - Accuracy (meters, error range)
  |       - Timestamp (when acquired)
  |
  ├─← Location acquired: {33.8688, 73.1012, accuracy: 15m}
  |
  └─→ Browser: Send to server
        {studentID, latitude, longitude, accuracy, timestamp}
```

### GPS Accuracy Considerations
```
Accuracy: How far off the true position could be
  |
  ├─ Excellent: 0-5 meters (rare indoors)
  ├─ Good: 5-20 meters (typical outdoors)
  ├─ Acceptable: 20-50 meters (urban area)
  ├─ Poor: 50-100+ meters (weak signal)
  ├─ Very Poor: 100+ meters (heavy obstruction, urban canyon)
  |
  └─ Indoors: 20-200+ meters
     (GPS through walls: weak or unreliable)
```

## Stage 3: Distance Calculation (Haversine Formula)

### Server-Side Calculation
```
Inputs:
  - Student location: (lat1, lon1)
  - Geofence center: (lat2, lon2)
  - Geofence radius: R meters
  
Algorithm: Haversine Formula
  (Most accurate for short distances)
  
  Δlat = lat2 - lat1
  Δlon = lon2 - lon1
  
  a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)
  c = 2 × asin(√a)
  d = R_earth × c
  
  Where:
  - R_earth = 6,371 km (Earth radius)
  - Result: distance in same units as R_earth
  
  Simplified (for <10km distances):
  d_meters = 111.3 × √((lat2-lat1)² + (lon2-lon1)²) × 1000
  
Output:
  distance = 32.45 meters (from geofence center)
```

### Accuracy Considerations
```
Calculation Error Sources:
  1. Student GPS accuracy (±15m typical)
  2. Geofence coordinate precision
  3. Earth curvature (negligible for <1km)
  4. Rounding errors (negligible)
  
Net Effect:
  - Calculated distance ± GPS accuracy
  - True distance could be 30±15 = 15-45m range
  - Must account for this in geofence decision
```

## Stage 4: Geofence Decision

### Decision Logic
```
Calculated Distance = 32.45 meters
Geofence Radius = 50 meters
Accuracy Margin = GPS_accuracy (e.g., 15m)

Logic 1: Simple Distance Check
  ├─ If distance <= radius:
  │   └─ INSIDE geofence ✓
  └─ If distance > radius:
      └─ OUTSIDE geofence ✗

Logic 2: Confidence-Based (Recommended)
  ├─ If (distance - accuracy) <= radius:
  │   └─ Likely INSIDE (high confidence)
  ├─ If (distance + accuracy) > radius:
  │   └─ Likely OUTSIDE (high confidence)
  └─ Else (uncertain region):
      └─ AMBIGUOUS (accuracy overlap)
      
Example with 15m accuracy:
  - Distance: 32m, Accuracy: ±15m
  - Range: 17-47m
  - Radius: 50m
  - Decision: (32 + 15 = 47m) <= 50m
  - Result: INSIDE (with margin) ✓

Logic 3: Strict Verification (Extra Security)
  ├─ If distance <= (radius - buffer):
  │   └─ INSIDE (with safety margin)
  │   (e.g., 32m <= 40m = YES)
  ├─ If distance > radius:
  │   └─ OUTSIDE
  └─ Else (in buffer zone):
      └─ Require refresh/manual verify
```

## Stage 5: Result Scenarios

### Scenario A: Student Inside Geofence ✓

```
Distance: 32 meters
Radius: 50 meters
Result: INSIDE ✓

Browser Display:
  ├─ "✓ Location Verified"
  ├─ "You are in the classroom"
  ├─ Distance: 32m from center
  └─ Continue with registration

Server:
  ├─→ Store in AttendanceRecords
  │   - locationVerified = true
  │   - distance = 32m
  │   - GPSAccuracy = 15m
  │
  └─ Proceed to next step
```

### Scenario B: Student Outside Geofence ✗

```
Distance: 85 meters
Radius: 50 meters
Result: OUTSIDE ✗

Browser Display:
  ├─ "⚠ Location Not Verified"
  ├─ "You appear to be outside the classroom"
  ├─ Distance: 85m from center
  ├─ Options:
  │  1. [Refresh Location] - Re-acquire GPS
  │  2. [Manual Override] - Proceed anyway
  │  3. [Contact Lecturer] - Request help
  ├─ Server may allow/deny based on policy
  └─ Lecturer might: Allow, Deny, or Investigate

Server Log:
  ├─ flag: OUTSIDE_GEOFENCE
  ├─ Alert: Possible remote attendance attempt
  ├─ Require: Manual lecturer approval
  └─ Store: Full event for audit trail
```

### Scenario C: GPS Unavailable/Timeout

```
GPS Request: Timeout after 30 seconds
Result: No location acquired

Browser Display:
  ├─ "✗ Unable to Get Location"
  ├─ Reasons offered:
  │  - "GPS signal too weak (indoor location)"
  │  - "Permission denied by user"
  │  - "GPS not available on this device"
  ├─ Options:
  │  1. [Try Again] - Retry GPS acquisition
  │  2. [Allow Without Location] - Skip verification
  │  3. [Contact Lecturer] - Request assistance
  └─ Timeout/Manual action required

Server Policy:
  ├─ Strict: Reject registration (deny)
  ├─ Moderate: Allow with flag (proceed + flag)
  └─ Lenient: Allow without verification (proceed)
```

### Scenario D: Ambiguous/Borderline (Confidence-Based)

```
Distance: 45 meters
Accuracy: ±20m (weak GPS signal)
Radius: 50 meters
Actual range: 25-65m

Result: AMBIGUOUS (overlaps geofence)

Browser Display:
  ├─ "⚠ Location Uncertain"
  ├─ "GPS signal is weak - Please try to improve signal"
  ├─ Options:
  │  1. [Refresh Location] - Move to clearer area + retry
  │  2. [Proceed Anyway] - Continue despite uncertainty
  │  3. [Wait] - Wait for better signal
  └─ Manual lecturer override possible

Server:
  ├─ Store: locationUncertain = true
  ├─ Allow: With flag for auditing
  └─ Alert: Lecturer of borderline case
```

## Stage 6: Location Refresh Button

### Contextual Refresh
```
When Shown:
  - Student outside geofence OR
  - Location accuracy poor OR
  - Student requests refresh

User Action:
  ├─→ Student: Moves to different location
  ├─→ Student: Taps [Refresh Location]
  ├─→ Browser: Request GPS again (fresh signal)
  └─→ Server: Recalculate distance
  
Benefit:
  - No need to restart entire registration
  - Student can move and retry within geofence
  - GPS signal often improves after move
  - Reduces friction for edge cases
```

## Stage 7: Logging & Audit

### Data Stored
```
INSERT INTO GPSLocations (
  locationID,
  recordID,           // AttendanceRecord reference
  latitude,
  longitude,
  altitude,
  accuracy,
  timestamp,
  provider           // GPS / Network / Fused
);

UPDATE AttendanceRecords SET
  isLocationVerified = true/false,
  locationVerified_time = timestamp,
  distance_from_geofence = 32m,
  accuracy_range = ±15m
;
```

### Audit Trail
```
- All GPS requests logged (with timestamp)
- All location decisions logged
- Outside geofence attempts noted
- Failed GPS acquisition recorded
- Manual overrides logged
- Lecturer approval stored
```

## Edge Cases & Limitations

```
Limitation 1: GPS Unreliability Indoors
  └─ Classrooms with heavy shielding: unreliable
  └─ Solution: Use WiFi geolocation (less accurate)
  
Limitation 2: Accidental Outside Readings
  └─ Building edge (GPS bounce): false positive
  └─ Solution: Refresh button, manual override
  
Limitation 3: GPS Spoofing
  └─ Attacker fakes GPS coordinates
  └─ Mitigation: Combined with face + device verification
  
Limitation 4: Urban Canyon Effect
  └─ Tall buildings reflect signals: poor accuracy
  └─ Solution: Larger radius, manual verification
  
Limitation 5: Delayed Fix (Cold Start)
  └─ First GPS fix takes 30-60 seconds
  └─ Solution: Reduce timeout, pre-warm GPS
```

## Configuration Best Practices

```
Geofence Radius Recommendations:

Small classroom (< 50 people):
  └─ Radius: 30-50m (tighter control)
  
Large lecture hall (100+ people):
  └─ Radius: 50-75m (accommodate size)
  
Outdoor venue:
  └─ Radius: 75-150m (more forgiving of GPS error)
  
Campus building (could use multiple rooms):
  └─ Radius: 100m+ (flexible)

Time Window:
  └─ GPS timeout: 20-30 seconds
  └─ Refresh timeout: 10-15 seconds
```

## Success Criteria
- Geofence configuration shown
- GPS acquisition process visible
- Distance calculation explained
- Decision tree clear (inside/outside/ambiguous)
- Error scenarios handled
- Refresh mechanism shown
- Logging and audit trail documented
- Edge cases and limitations noted
- User feedback at each stage
- Lecturer override options visible

## Tools Suitable For
- Draw.io
- Lucidchart
- Miro/Mural
- PlantUML
- Google Maps integration diagram

## Related Sections in Final_Doc
- Section 7.4: GPS Verification & Geofencing Flow
- Section 7: Security & Authentication
