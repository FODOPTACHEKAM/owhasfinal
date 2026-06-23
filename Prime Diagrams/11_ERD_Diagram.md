# Figure 4.11: Entity Relationship Diagram

## Purpose
Shows the database structure of OwHAS with entities, attributes, and relationships.

## Diagram Type
**Entity-Relationship Diagram (Crow's Foot Notation)**

## Entities

### 1. Lecturer
| Attribute | Type | Constraint | Description |
|-----------|------|------------|-------------|
| **lecturer_id** | String | PK | Unique identifier (Firebase UID) |
| name | String | NOT NULL | Lecturer's full name |
| email | String | UNIQUE, NOT NULL | Login email |
| password_hash | String | NOT NULL | Hashed password (Firebase Auth) |
| signature_data | Text | NULLABLE | Digital signature image data |
| profile_image | String | NULLABLE | Profile photo URL |
| created_at | DateTime | NOT NULL | Account creation timestamp |

### 2. Session
| Attribute | Type | Constraint | Description |
|-----------|------|------------|-------------|
| **session_id** | String | PK | Unique session identifier |
| *lecturer_id* | String | FK → Lecturer | Session creator |
| course_name | String | NOT NULL | Name of the course |
| course_code | String | NOT NULL | Course code (e.g., ICT301) |
| pin | String(4) | NOT NULL | 4-digit access PIN |
| start_time | DateTime | NOT NULL | Session start timestamp |
| end_time | DateTime | NULLABLE | Session end timestamp |
| duration_minutes | Integer | NOT NULL | Configured duration |
| status | Enum | NOT NULL | NOT_STARTED, ACTIVE, PAUSED, ENDED |
| geofence_lat | Double | NULLABLE | Geofence center latitude |
| geofence_lng | Double | NULLABLE | Geofence center longitude |
| geofence_radius | Double | NULLABLE | Geofence radius in meters |
| created_at | DateTime | NOT NULL | Record creation timestamp |

### 3. AttendanceRecord
| Attribute | Type | Constraint | Description |
|-----------|------|------------|-------------|
| **record_id** | String | PK | Unique record identifier |
| *session_id* | String | FK → Session | Parent session |
| student_name | String | NOT NULL | Student's full name |
| matric_number | String | NOT NULL | Matriculation number |
| email | String | NULLABLE | Student email |
| face_descriptor | JSON | NULLABLE | 128-dim face embedding array |
| face_verified | Boolean | DEFAULT false | Face verification passed |
| is_duplicate | Boolean | DEFAULT false | Flagged as duplicate face |
| device_fingerprint | String | NULLABLE | Device unique identifier |
| device_info | JSON | NULLABLE | OS, model, browser details |
| gps_latitude | Double | NULLABLE | Student GPS latitude |
| gps_longitude | Double | NULLABLE | Student GPS longitude |
| gps_accuracy | Double | NULLABLE | GPS accuracy in meters |
| signature_data | Text | NULLABLE | Digital signature image |
| timestamp | DateTime | NOT NULL | Registration timestamp |

### 4. Student (Aggregated View)
| Attribute | Type | Constraint | Description |
|-----------|------|------------|-------------|
| **matric_number** | String | PK | Unique student identifier |
| name | String | NOT NULL | Student's full name |
| email | String | NULLABLE | Student email |
| total_sessions | Integer | COMPUTED | Number of sessions attended |
| last_attended | DateTime | COMPUTED | Most recent attendance |
| device_ids | JSON | NULLABLE | List of device fingerprints used |

## Relationships

### Lecturer → Session
- **Type:** One-to-Many (1:N)
- **Description:** One lecturer creates many sessions
- **FK:** Session.lecturer_id → Lecturer.lecturer_id
- **Rule:** A session must belong to exactly one lecturer

### Session → AttendanceRecord
- **Type:** One-to-Many (1:N)
- **Description:** One session contains many attendance records
- **FK:** AttendanceRecord.session_id → Session.session_id
- **Rule:** An attendance record must belong to exactly one session
- **Cascade:** If session is deleted, all its records are deleted

### Student → AttendanceRecord
- **Type:** One-to-Many (1:N)
- **Description:** One student can appear in many attendance records (across sessions)
- **FK:** AttendanceRecord.matric_number → Student.matric_number
- **Rule:** A student can attend many different sessions

### Student ↔ Session (via AttendanceRecord)
- **Type:** Many-to-Many (M:N)
- **Description:** Many students attend many sessions
- **Junction Table:** AttendanceRecord serves as the junction/bridge table
- **Note:** The M:N relationship is resolved through AttendanceRecord

## ER Diagram (Text Representation)
```
[Lecturer] ──1────────N──→ [Session]
                              |
                              1
                              |
                              N
                              ↓
                        [AttendanceRecord]
                              ↑
                              N
                              |
                              1
                              |
                          [Student]
```

## Indexes
| Table | Index | Columns | Purpose |
|-------|-------|---------|---------|
| Session | idx_session_lecturer | lecturer_id | Fast lookup by lecturer |
| Session | idx_session_pin | pin | Fast PIN validation |
| AttendanceRecord | idx_record_session | session_id | Fast lookup by session |
| AttendanceRecord | idx_record_matric | matric_number | Fast lookup by student |
| AttendanceRecord | idx_record_device | device_fingerprint | Duplicate device detection |

## Drawing Instructions
1. Draw 4 entity rectangles with attributes listed inside
2. Mark PK (primary key) with underline, FK (foreign key) with italic
3. Use Crow's Foot notation for cardinality:
   - One side: single line
   - Many side: crow's foot (three-pronged fork)
4. Draw relationship lines between entities
5. Label each relationship
6. Show the junction nature of AttendanceRecord

## Tools
- Draw.io / diagrams.net
- dbdiagram.io
- Lucidchart
- MySQL Workbench
- Enterprise Architect
