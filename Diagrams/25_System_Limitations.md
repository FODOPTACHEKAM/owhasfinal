# Diagram 25: System Limitations & Constraints

## Purpose
Show technical limitations, constraints, and edge cases of OWHAS system.

## Type
**Constraints & Limitations Diagram / Risk Matrix**

## Hardware Limitations

### Lecturer Device Constraints

```
┌─────────────────────────────────────────────┐
│       LECTURER DEVICE LIMITATIONS          │
└─────────────────────────────────────────────┘

CPU Constraint:
  ├─ Minimum requirement: 2 cores @ 2.0 GHz
  ├─ Impact: Can handle 50-100 students
  ├─ Bottleneck: Face verification (CPU intensive)
  ├─ On 1 core: Can't sustain required throughput
  └─ Workaround: Distribute processing or increase specs

Memory Constraint:
  ├─ Minimum: 4GB RAM
  ├─ With 4GB:
  │  ├─ OS: 1.5GB
  │  ├─ Node.js + database: 1GB
  │  ├─ Browser (50 concurrent): 1-1.5GB
  │  └─ Headroom: ~500MB (tight!)
  ├─ Problem: OOM crashes possible with 80+ students
  ├─ With 8GB: Comfortably supports 100+ students
  └─ Workaround: Use cloud deployment for large sessions

WiFi Hardware Constraint:
  ├─ 802.11n (older device):
  │  ├─ Max concurrent: 20-30 devices
  │  ├─ Bandwidth: 150 Mbps (theoretical)
  │  └─ Issue: Crowded 2.4GHz, slow
  ├─ 802.11ac (modern):
  │  ├─ Max concurrent: 50-100 devices
  │  ├─ Bandwidth: 1300+ Mbps
  │  └─ Better: 5GHz band available
  ├─ 802.11ax (WiFi 6):
  │  ├─ Max concurrent: 200+ devices
  │  └─ Best performance
  └─ Limitation: Device determines max students

Battery Constraint:
  ├─ On laptop battery: 2-4 hours typical
  ├─ Node.js + WiFi hotspot: High power consumption
  ├─ Problem: Session interrupted when battery dies
  └─ Workaround: Connect to power supply
```

### Student Device Constraints

```
┌────────────────────────────────────────────┐
│        STUDENT DEVICE LIMITATIONS         │
└────────────────────────────────────────────┘

Old Smartphone Constraints:
  ├─ RAM: 1-2GB
  ├─ CPU: Single or dual core, slow
  ├─ Issue: Browser crashes loading face-api.js
  ├─ Issue: Face detection takes 30+ seconds
  └─ Workaround: None (device too slow)

Processor Speed:
  ├─ Modern phone: 2-3 GHz (multicore)
  │  └─ Face detection: 1-2 seconds
  ├─ Old phone: 1 GHz
  │  └─ Face detection: 10-30 seconds
  ├─ Impact: User frustration with slow device
  └─ Threshold: 1.5+ GHz recommended minimum

Camera Quality:
  ├─ Requirement: Functional camera (most phones have)
  ├─ Issue: Low-light camera may not detect faces
  ├─ Issue: Damaged lens = no face detection
  ├─ Impact: Student can't register
  └─ Workaround: Lecturer manually verifies

Internet Connection:
  ├─ WiFi on hotspot: Always available (if close)
  ├─ 3G/4G: Not available in offline mode
  ├─ Issue: Student outside WiFi range
  ├─ Impact: Can't connect to hotspot
  └─ Workaround: Move closer to lecturer
```

## Geographic & Environmental Limitations

### WiFi Range Limitations

```
┌────────────────────────────────────────────┐
│           WiFi RANGE CONSTRAINTS          │
└────────────────────────────────────────────┘

Indoor Range (typical classroom):
  ├─ 2.4GHz band:
  │  ├─ Best case: 30-50 meters (open space)
  │  ├─ Realistic: 10-20 meters (classroom)
  │  ├─ With walls: 5-10 meters per wall
  │  └─ Issue: Thick walls block signal
  │
  ├─ 5GHz band:
  │  ├─ Best case: 20-30 meters (less penetrating)
  │  ├─ Realistic: 5-15 meters (classroom)
  │  └─ Better: Faster but shorter range
  │
  └─ Impact: Large lecture halls may have dead zones

Outdoor Range:
  ├─ Open field: 50-100 meters typical
  ├─ Urban area: 20-50 meters (interference)
  ├─ No obstruction: ~75 meters
  └─ Issue: Multiple classrooms → need multiple hotspots

Signal Interference:
  ├─ Microwave ovens: Interfere with 2.4GHz
  ├─ Other WiFi networks: Channel overlap
  ├─ Bluetooth: Runs on same 2.4GHz spectrum
  ├─ Problem: Performance degradation in crowded areas
  └─ Solution: Use 5GHz band if available
```

### GPS Limitations

```
┌────────────────────────────────────────────┐
│           GPS ACCURACY CONSTRAINTS        │
└────────────────────────────────────────────┘

Outdoor Accuracy:
  ├─ Ideal (open sky): ±5 meters (95% confidence)
  ├─ Urban canyon: ±10-30 meters
  ├─ Issue: High-rises block satellites
  └─ Mitigation: Increase geofence radius tolerance

Indoor Accuracy:
  ├─ Building interior: ±50+ meters (unreliable)
  ├─ Basement: No signal possible
  ├─ Issue: Can't reliably detect if indoors
  └─ Workaround: Use IP location as fallback

Satellite Acquisition Time (TTFF):
  ├─ Cold start (no prior data): 30-120 seconds
  ├─ Warm start (cached data): 5-30 seconds
  ├─ Hot start (just initialized): 1-5 seconds
  ├─ Issue: Students wait 30+ seconds outside
  └─ Workaround: Acceptable for outdoor venues only

Accuracy Trade-off:
  ├─ Problem: Larger geofence → Less accurate
  ├─ Example: 50m radius = ±75m total
  ├─ May include students outside venue
  └─ Workaround: Combine with other verification

Spoofing Risk:
  ├─ Threat: GPS spoofing attacks
  ├─ Mitigation: Combine with face recognition
  └─ Security: Defense-in-depth approach
```

### Climate & Environmental Constraints

```
Extreme Weather:
  ├─ High temperature: Device throttles, slows down
  ├─ Low temperature: Battery dies quickly
  ├─ Rain: WiFi still works, but wet devices risky
  ├─ Snow: Signal attenuation possible
  └─ Impact: Performance degradation in bad weather

Lighting Conditions:
  ├─ Bright sunlight: Face detection still works
  ├─ Low light: Difficult to detect faces
  ├─ Issue: Evening classes outside may fail
  ├─ Backlight problem: Classroom lights behind student
  └─ Workaround: Position camera properly, improve lighting
```

## Data Volume Limitations

### Database Scale Constraints

```
┌─────────────────────────────────────────────┐
│       DATABASE SCALE CONSTRAINTS           │
└─────────────────────────────────────────────┘

Single Device Offline Mode:
  ├─ Total storage capacity: 1TB (typical laptop)
  ├─ Database usage: ~100MB per 1000 sessions
  ├─ With 100 sessions/year: ~10GB/year (5-year use)
  ├─ Problem: Full disk after 50-100 years (unlikely)
  ├─ Realistic scenario: 500GB used after 5 years
  └─ Impact: None (drives typically larger)

Concurrent Users Single Instance:
  ├─ Max students registering simultaneously: 50
  ├─ Beyond 50: Response times degrade
  ├─ Max before failure: ~100 concurrent
  ├─ Problem: Can't support large lectures
  └─ Workaround: Use cloud deployment or multiple servers

Single Lecture Session:
  ├─ Recommended max: 200-500 students
  ├─ Database table size: ~100MB (500 students × 200KB each)
  ├─ Beyond 500: Query performance degrades
  ├─ Problem: End-of-year reports slow (1000+ records)
  └─ Workaround: Archive old data, use batch processing
```

### Network Bandwidth Limitations

```
Home Internet (typical):
  ├─ Upload speed: 5-20 Mbps
  ├─ Download speed: 50-100 Mbps
  ├─ Problem: Uploading 50 sessions (100GB) takes hours
  ├─ Impact: Cloud sync limited by upload speed
  └─ Workaround: Sync off-peak, use compression

Cloud Sync Data:
  ├─ Per session: 5-50MB (attendance records)
  ├─ 50 sessions: 250MB-2.5GB total
  ├─ Issue: 250MB upload at 10 Mbps = 3.5 hours
  └─ Optimization: Compress + batch upload

Concurrent User Bandwidth:
  ├─ PIN verification: 100 bytes per request
  ├─ 50 students simultaneously: 5KB/request
  ├─ Response: 400 bytes each = 20KB/response
  ├─ 5 KB + 20 KB = 25 KB per round
  ├─ Rate: 1-2 requests/second
  └─ Total: 25-50 KB/second = Well within limits
```

## Functional Limitations

### Face Recognition Limitations

```
┌─────────────────────────────────────────────┐
│     FACE RECOGNITION CONSTRAINTS           │
└─────────────────────────────────────────────┘

Identification Range:
  ├─ Best: 0.5-2 meters away from camera
  ├─ Issue: Too close (< 20cm) = blurry
  ├─ Issue: Too far (> 3m) = too small
  ├─ Impact: Poor user experience with improper distance
  └─ Workaround: Guide user to correct distance

Angle Constraint:
  ├─ Face must be mostly frontal
  ├─ Side angle: May not detect (profile view)
  ├─ Top-down angle: May not detect
  ├─ Extreme angles: Fails completely
  ├─ Threshold: ±30 degrees acceptable
  └─ Issue: User looking away = no detection

Age/Gender Variation:
  ├─ Model trained on mixed population
  ├─ Better accuracy: Adults 18-65 years
  ├─ Children (< 10): May have poor accuracy
  ├─ Elderly (> 75): May have poor accuracy
  └─ Impact: Limited for very young or very old students

Disguise Vulnerability:
  ├─ Thick beard change: May not match past
  ├─ Glasses on/off: May reduce accuracy
  ├─ Makeup: Usually okay (face shape unchanged)
  ├─ Face mask: Fails completely (50% face obscured)
  ├─ Hat/sunglasses: May still detect if face visible
  └─ Workaround: Manual verification by lecturer

Physical Similarity:
  ├─ Twins: High false positive rate (92% similarity)
  ├─ Siblings: Possible confusion (70-80% similarity)
  ├─ Lookalikes: May trigger duplicate alert
  ├─ Threshold: 0.6 distance (configurable)
  └─ Workaround: Lecturer manual override

Quality Requirement:
  ├─ Lighting: Moderate to good lighting required
  ├─ Resolution: 640x480 minimum
  ├─ Focus: Must be in focus
  ├─ Backlight: Avoid (image too dark)
  └─ Recommendation: Indoor classroom lighting optimal
```

### Session Duration Limitations

```
Single Session Duration:
  ├─ Typical: 2-3 hours (semester course)
  ├─ Max recommended: 8 hours continuous
  ├─ Problem: Continuous 8+ hours → service degradation
  ├─ Issue: Database locks, memory leaks possible
  └─ Workaround: Split into multiple sessions

Late Arrivals:
  ├─ Grace period: 0-30 minutes (configurable)
  ├─ Problem: Late arrivals flagged as tardy in SIS
  ├─ Impact: Fairness issue for students
  └─ Workaround: Lecturer manual adjustment

Early Departures:
  ├─ Issue: Student leaves early (partial attendance)
  ├─ Recorded as: Attended (timestamp present)
  ├─ Problem: Can't detect early departure
  ├─ Impact: Inaccurate attendance record
  └─ Workaround: Lecturer manual sign-out required
```

## Scalability Limitations

### Single Instance Constraints

```
┌───────────────────────────────────────────────┐
│     SINGLE SERVER SCALABILITY LIMITS         │
└───────────────────────────────────────────────┘

Concurrent Connection Limit:
  ├─ Node.js default: 10 simultaneous connections
  ├─ Configurable to: 1000+ connections
  ├─ Database connection pool: 20-50
  ├─ Physical limit: OS max file descriptors
  ├─ Typical server: 10,000+ simultaneous connections
  └─ OWHAS target: 200-500 concurrent students

Memory Limitation:
  ├─ 8GB server: Can cache ~5GB data in memory
  ├─ Growth: Each student adds ~10MB to memory
  ├─ 500 students: ~5GB = Fully utilized
  ├─ Beyond 500: Out-of-memory errors
  └─ Upgrade: Add more RAM or add servers

Disk I/O Bottleneck:
  ├─ SSD typical: 100,000 IOPS
  ├─ Database: 500-1000 IOPS per session (typical)
  ├─ Reports: 1000-5000 IOPS per report generation
  ├─ Peak: All 500 students ending session simultaneously
  ├─ Overload: > 50,000 IOPS = Degradation
  └─ Mitigation: Distribute across multiple disks (RAID)

CPU Bottleneck:
  ├─ 4-core server: Can execute 4 tasks parallel
  ├─ Face processing: CPU intensive (face-api.js)
  ├─ Report generation: CPU intensive (PDF rendering)
  ├─ Peak: 50 face verifications + 1 report = CPU at 100%
  └─ Solution: Use cloud server with more cores
```

## Operational Limitations

### Support & Maintenance Constraints

```
Institutional Mode Support:
  ├─ Expected: 24/7 support (not always available)
  ├─ Realistic: 8-5 business hours + on-call
  ├─ Issue: 3AM crash = no immediate support
  ├─ Impact: Service down until business hours
  └─ Workaround: Auto-restart, redundancy

Maintenance Windows:
  ├─ Offline mode: Can't do maintenance (live use)
  ├─ Cloud mode: Maintenance during low usage hours
  ├─ Issue: During maintenance = service unavailable
  ├─ Impact: Can't schedule during peak hours
  └─ Solution: Load balancer + multiple servers

Backup & Recovery:
  ├─ Offline mode: Manual backup required (tedious)
  ├─ Cloud mode: Automatic backup (managed)
  ├─ Issue: Old backups = data loss if recent corruption
  ├─ Recovery time: 30+ minutes typical
  └─ RPO (Recovery Point Objective): Hourly for offline
```

## Success Criteria
- All major limitations documented
- Hardware constraints specified
- Geographic limitations explained
- Data volume constraints shown
- Functional limitations detailed
- Scalability limits defined
- Operational constraints listed
- Workarounds provided for each
- Risk mitigation strategies included
- Impact of each limitation assessed

## Tools Suitable For
- Draw.io
- Lucidchart
- Risk matrix
- Constraint diagrams

## Related Sections in Final_Doc
- Section 12: System Limitations & Edge Cases
