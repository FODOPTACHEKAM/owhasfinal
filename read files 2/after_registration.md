# After Registration — What Happens When a Student Wants to Register for Another Course

This document traces exactly what the app does after a student finishes registering,
and what happens — step by step — if they immediately try to register for a second course.

---

## 1. What Happens Right After Successful Registration

When `_registerViaSession` or `_registerDirect` succeeds, `_showSuccessDialog()` is called:

```dart
// student_registration_screen.dart
void _showSuccessDialog() {
  showDialog(context: context, barrierDismissible: false,
      builder: (_) => SuccessDialog(onDismissed: _resetForm));
}
```

`SuccessDialog` does two things:

1. Shows a green animated card with "Registered Successfully!" and "Stay connected for verification".
2. After **exactly 2 seconds**, auto-dismisses itself and calls `onDismissed` → `_resetForm()`.

```dart
// success_dialog.dart
Future.delayed(const Duration(seconds: 2), () {
  if (mounted) { Navigator.pop(context); widget.onDismissed?.call(); }
});
```

`_resetForm()` puts the screen back to its initial state — step 0 (PIN entry) — with all fields cleared:

```dart
void _resetForm() => setState(() {
  _currentStep = 0; _errorMessage = null; _pinVerifyState = PinVerifyState.idle;
  _statusMessage = 'Enter the 4-digit PIN from your instructor.';
  for (final c in [_pinController, _matriculeCtrl, _nameCtrl, _emailCtrl]) { c.clear(); }
});
```

**The student does not leave the registration screen.** There is no automatic navigation to Home.
They are sitting on the PIN-entry step, fields blank, ready to start again.

---

## 2. Two Registration Paths — Which One Runs?

The screen has two internal registration paths that behave very differently:

```dart
// student_registration_screen.dart — _captureAndRegister()
final session = context.read<SessionStateNotifier>().activeSession;

if (session == null) {
  await _registerDirect(...);   // ← PATH A: student's own phone
} else {
  await _registerViaSession(...); // ← PATH B: shared / lecturer's phone
}
```

| | Path A — `_registerDirect` | Path B — `_registerViaSession` |
|---|---|---|
| When | No local session on the phone | A local session exists on the phone |
| Typical device | Student's own phone | Lecturer's phone used as shared terminal |
| Device fingerprint check | **No** | **Yes** (blocks same device re-registering) |
| Face duplicate check | **No** | **Yes** (blocks proxy attendance) |
| Record stored locally | **No** | **Yes** (in `StorageService`, scoped to the local session) |
| Record sent to server | **Yes** (`/connect`) | **Yes** (`/connect` + local storage) |

Understanding which path runs determines what blocks or allows a second registration.

---

## 3. Scenario A — Student Wants to Register for the Same Course Again

The student finishes registering for **Course A (PIN: 1234)** and, after the success dialog,
mistakenly enters **PIN 1234 again**.

### Path A (own phone, no local session)

| Step | What happens |
|---|---|
| PIN verify | `ApiService().verifySessionPin('1234')` → server responds 200 → PIN accepted |
| Details | Student fills same matricule and name |
| Face capture | `FaceCapturePage` runs — no face duplicate check in this path |
| Server registration | `POST /connect` → server finds `matricule` already in `session.attendees` → returns HTTP 200 with body `"You are already registered for this session."` |
| Flutter reaction | `ApiService.registerStudentOnServer` treats any 200 as success → `_showSuccessDialog()` runs again |

**Result:** A second success dialog appears but no new record is created on the server.
The duplicate is silently absorbed. The student is not actually double-registered.

### Path B (shared phone, local session active)

| Step | What happens |
|---|---|
| PIN verify | Accepted (server session still active) |
| Details + face | Face capture runs |
| Face duplicate check | `faceService.findDuplicate(session.id, descriptor)` — the face was stored during the first registration → **BLOCKED** with: `"This face is already registered under [name]. Proxy attendance is not allowed."` |

**Result:** Registration is rejected at the face step. The student is told they have already registered.

---

## 4. Scenario B — Student Wants to Register for a Different Course

The student finishes registering for **Course A (PIN: 1234)** and now wants to register for
**Course B (PIN: 5678)**, which belongs to a different lecturer's session.

### Path A (own phone, no local session) — the clean path

All checks that could block are session-scoped.
Since PIN 5678 belongs to a **different session with a different session ID**, every check
starts with a clean slate:

| Check | Scope | Result for Course B |
|---|---|---|
| PIN verify | Server looks up PIN 5678 | Passes if the second session is active |
| Device fingerprint | `StorageService.getAttendanceRecords(session.id)` — scoped to the local session | No local records exist → no block (**Path A skips this entirely**) |
| Face duplicate | `FaceRecognitionService._sessions[sessionId]` — keyed by session ID | Different session ID → empty face map → no block (**Path A skips this entirely**) |
| Server matricule check | Server checks attendees for PIN 5678 only | Student not yet registered for this session → allowed |

**Result:** The student registers successfully for Course B. They receive a second success dialog
and the second record is added to the Course B session on the server.

### Path B (shared phone, local session active) — the mixed path

When the phone has a local active session (e.g. Course A), `_registerViaSession` is called
with the **local** session object regardless of what PIN the student typed.

```dart
final session = context.read<SessionStateNotifier>().activeSession; // ← always Course A's session
await _registerViaSession(rn: rn, session: session, ...);
```

| Check | Scope | Result for Course B |
|---|---|---|
| Device fingerprint | Checks records of the **local Course A session** | Student already has a record there → **BLOCKED** |
| Face duplicate | Checks face map of the **local Course A session** | Student's face is in there → **BLOCKED** |

**Result:** Both checks fire against Course A's data. The student is blocked from registering
for Course B on a shared device because the device fingerprint and face descriptor were already
stored under Course A.

**Workaround for Path B / shared device:**
The lecturer removes the student's Course A record from the dashboard (which also removes the
stored face and fingerprint for that session), freeing them to register again. Or the student
uses their own phone (Path A) where none of these local checks apply.

---

## 5. Summary Table

| Situation | Own phone (Path A) | Shared/lecturer phone (Path B) |
|---|---|---|
| Register for Course B after Course A | **Works** — all checks are session-scoped | **Blocked** — fingerprint and face stored under Course A |
| Register for Course A again (same PIN) | Silent duplicate absorbed by server | Blocked at face step: "face already registered" |
| Register for Course A again (different matricule, same device) | Allowed by server (different matricule) | Blocked at fingerprint step: "device already used" |

---

## 6. What the Student Must Do

When the student wants to register for a second course:

1. Wait for the success dialog to auto-dismiss (2 seconds).
2. The form resets to the PIN step automatically — they do not need to navigate away.
3. Enter the **new 4-digit PIN** shown by the second course's lecturer.
4. Fill in their details (same matricule and name — they have to type again, fields are cleared).
5. Take a new selfie.
6. A second success dialog confirms registration for the second course.

If registration for the second course fails with a "device already used" error, the student
is on a shared device. They should ask their lecturer to remove their record from the
dashboard and try again, or use their own phone.

---

## 7. Code Path Summary

```
SuccessDialog auto-dismisses after 2 seconds
    │
    ▼
_resetForm() called
  _currentStep = 0
  all TextEditingControllers cleared
  screen stays on StudentRegistrationScreen
    │
    ▼
Student enters new PIN
    │
    ▼
_verifyPin()
  ApiService().verifySessionPin(newPin)  ← server check, no local state used
    │
    ├─ invalid / no session → error shown, stays on PIN step
    └─ valid → moves to step 1
    │
    ▼
Student fills details → step 2 → _captureAndRegister()
    │
    ├─ activeSession == null  →  _registerDirect()
    │     no fingerprint check
    │     no face check
    │     POST /connect with new PIN
    │
    └─ activeSession != null  →  _registerViaSession()
          face duplicate check  → keyed by LOCAL session.id
          fingerprint check     → keyed by LOCAL session.id
          if both pass: record saved to LOCAL session + POST /connect
```
