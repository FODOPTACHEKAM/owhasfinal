# Blink Detection in OwHAS — Risks and Considerations

---

## What Blink Detection Is Supposed to Do

Blink detection is a liveness check. Its purpose is to confirm that the face
in the camera is a real, living person and not a flat image — a printed photo,
a face displayed on another phone screen, or a still image held up to the
camera. The check works by capturing a short burst of frames during the face
step and analysing whether the student's eyes close and reopen naturally within
that window.

It sounds simple, but there are a significant number of risks across three
categories: risks that cause legitimate students to fail, risks that allow
spoofers to pass, and risks that affect the server and the session.

---

## Category 1 — False Failures (Legitimate Students Flagged as Spoofers)

These are the most serious risks because they directly harm students who are
doing nothing wrong.

### Lighting conditions in the classroom

Blink detection relies on accurately locating the eye corners and eyelid edges
in each frame. In poor lighting — a dark lecture hall, a room with strong
backlighting from windows, or uneven overhead lighting — the eye region becomes
unclear and the algorithm loses the landmarks it needs. A student in a dark
corner of the room may fail the check not because they did not blink, but
because their eyes were not clearly visible in any frame.

### Glasses

Glasses introduce reflections, distortion, and glare directly over the eye
region. The reflection from a classroom projector or ceiling light hitting the
lens can completely obscure one or both eyes in certain frames. A student
wearing glasses may blink perfectly and still fail because the algorithm could
not see the eye close clearly through the reflection.

### Blinking too fast or too slow

The algorithm measures the Eye Aspect Ratio — the ratio of eye height to eye
width — across frames and looks for it to drop sharply (eye closing) and then
recover (eye opening). A student who blinks very quickly (some people have
reflexively fast blinks) may produce a drop that lasts only one or two frames,
which can be below the algorithm's minimum detection window. A student who
blinks very slowly, or who squints rather than fully closing the eye, may
produce a curve that the algorithm does not recognise as a genuine blink.

### Students with eye conditions

Some students have medical conditions that affect blinking. Dry eye syndrome
causes infrequent, incomplete blinks. Blepharospasm causes involuntary
spasms. Bell's palsy can reduce or eliminate voluntary movement on one side of
the face. These students cannot be expected to produce a textbook blink on
command, and failing them on an attendance check because of a medical condition
is both unfair and a potential accessibility concern.

### Students with heavy eye makeup

Dark eyeliner, thick mascara, and heavy eye shadow alter the visible boundary of
the eyelid. The algorithm relies on detecting the exact position of the eyelid
edge. Heavy makeup can shift this perceived boundary and cause the Eye Aspect
Ratio to be computed incorrectly — sometimes making an open eye look partially
closed, and sometimes making a closed eye look still open.

### Phone held at the wrong angle or distance

If the student holds their phone too close, the face fills the frame and the
eye region is too large for the landmark model to accurately locate. If they hold
it too far, the face is too small and the eye region has too few pixels for
reliable landmark placement. Either extreme increases the chance of a false
failure.

### The instruction is unclear or missed

If the student does not read or understand the instruction — "blink once when
the camera is ready" — they may simply hold still and wait for something to
happen. The burst of frames captures an unblinking face. The check fails not
because of spoofing but because of a user experience problem.

---

## Category 2 — False Passes (Spoofers Getting Through)

These are risks where the check is defeated despite being in place.

### Video playback attack

A static photo fails blink detection easily. But a short video clip of a person
blinking — taken from social media, a recorded call, or shot by a co-conspirator
in advance — would pass the check. As long as the video shows the target person's
face blinking naturally, the Eye Aspect Ratio curve will look genuine. Blink
detection does not protect against video replay.

### Deepfake video

A deepfake tool can take a single photo of the target person and generate a
short video of that face performing any action, including blinking. This
technology is increasingly accessible. If the attacker has one clear photo of
the student they are impersonating and access to a basic deepfake application,
they can generate a convincing blink sequence. Blink detection offers no
protection against a deepfake video.

### Controlled slow fade on a screen

A sophisticated attacker can display a high-resolution face image on a phone
screen and slowly reduce the screen brightness in the eye region for one frame,
then restore it. This simulates the Eye Aspect Ratio drop of a blink. It is
harder to execute than simply showing a still image, but it is not technically
difficult for someone who is determined to cheat.

### Double-blink problem

If only a single blink is required, an attacker using a looping video only needs
the video to contain one visible blink. Requiring two blinks within the capture
window is slightly harder to replay but also increases the failure rate for
legitimate students.

---

## Category 3 — Server and Session Risks

### Increased payload per student

The current system receives one JPEG image per student at the face step. With
blink detection, the browser sends a burst of 10 to 15 frames — essentially a
one-second video clip. Even with compression, this is roughly 10 to 15 times the
data of a single image per student. On the school VLAN, where all students in a
class register within a few minutes of each other, this represents a significant
increase in simultaneous upload traffic. If the VLAN access point or the server's
network interface is a bottleneck, registration will slow down noticeably.

### Server processing bottleneck

Processing a 15-frame burst through the OpenCV liveness pipeline takes
considerably longer than analysing a single frame. Each burst requires loading
the frames, detecting the face in each one, extracting 68 landmarks per frame,
computing the Eye Aspect Ratio curve, and applying the blink detection logic.
If 30 students submit bursts within a 2-minute window at the start of class, the
server must process 30 parallel video analysis jobs. On a school server with
limited CPU, this can cause queue buildup and registration timeouts. Students
at the back of the queue will see their face step hang for many seconds.

### Timing window calibration is fragile

The blink detection window — how many milliseconds are given to detect a blink
— must be set carefully. Too short and fast blinkers miss it. Too long and
the server holds the job open longer, worsening the processing bottleneck under
load. Getting this right requires testing with the actual student population and
actual classroom hardware, not just a controlled lab environment.

### Failure handling complexity

With the current single-image flow, a failed face check produces one clear
outcome: the descriptor did not match, or the face was not detected. With blink
detection, there are multiple possible failure modes: face not detected in any
frame, face detected but no blink found, burst arrived corrupted, burst was
too short, EAR threshold not crossed. Each failure mode needs a clear error
message and a retry path. Without careful handling, students will see generic
errors and not know what went wrong or what to do next.

### Browser compatibility on mobile

Capturing a burst of frames from the camera inside a mobile browser is not as
reliable as capturing a single still image. Safari on iOS imposes strict limits
on `getUserMedia` and does not allow continuous frame capture in the same way
that desktop Chrome does. Some Android browsers in power-saving mode reduce
frame rate during capture. The actual frame count in the burst, and the timing
between frames, can vary widely across devices. This inconsistency makes the
EAR curve less reliable because the algorithm assumes frames arrive at a
consistent rate.

---

## What Blink Detection Does and Does Not Protect Against

| Spoofing method | Blink detection blocks it? |
|---|---|
| Printed photo held up to camera | ✓ Yes — photo cannot blink |
| Face displayed on another phone screen (still image) | ✓ Yes — screen shows no movement |
| Pre-recorded video of the target person blinking | ✗ No — blink is present in video |
| Deepfake video generated from a single photo | ✗ No — AI-generated blink looks real |
| Controlled screen brightness fade simulating a blink | ✗ No — produces EAR curve |
| Student registering with their own face from outside the classroom | ✗ No — blink detection does not verify location |

Blink detection closes the easiest and most common attack (a static image) but
does not close attacks that involve video. The question is whether the remaining
attack surface — video replay and deepfakes — is a realistic threat in your
specific student population and context.

---

## Summary of Risks by Severity

| Risk | Severity | Affects |
|---|---|---|
| Legitimate student fails due to poor lighting | High | Common scenario in any lecture hall |
| Legitimate student fails due to glasses | High | A significant portion of students |
| Legitimate student fails due to fast or incomplete blink | Medium | Unpredictable — depends on the individual |
| Legitimate student fails due to eye condition or makeup | Medium | Smaller subset but cannot be dismissed |
| Server bottleneck under simultaneous registrations | High | Every session with a large class |
| Increased VLAN payload causing slowdowns | Medium | Depends on access point capacity |
| Mobile browser inconsistency in frame capture | High | iOS Safari in particular |
| Video replay attack passing the check | High | Defeats the main purpose |
| Deepfake attack passing the check | Medium | Requires attacker effort but is feasible |
| Students confused by the instruction | Low | Mostly first-time users |

---

## Conclusion

Blink detection meaningfully raises the bar against the simplest spoofing
attempt — a static image — and is worth implementing if that is the primary
threat. However, it introduces a real risk of false failures in classroom
conditions (lighting, glasses, device variation), a non-trivial server load
problem when many students register simultaneously, and unreliable behaviour
on iOS. It also does not protect against video replay, which is the next
easiest attack after a still image.

The safest approach is to treat blink detection as an optional, per-session
feature that the lecturer enables only for high-stakes sessions — exams or
graded labs — where the threat of deliberate spoofing justifies the added
friction and the risk of occasional false failures. For standard lecture
sessions, texture analysis on a single frame catches the common case with
none of the drawbacks listed above.
