# Server Status — How It Works

## 1. Detection at Startup

When the Flutter app launches it runs `ServerConfig().detect()`, which probes servers in this order (optimised for the common online/cloud use-case):

| Step | URL | Timeout | What happens |
|---|---|---|---|
| **1** | `https://owhas.org` | 2 s | **Cloud first** — fast path; returns immediately if reachable |
| 2 | All local IPs (LAN scan) | 800 ms | Fixed gateways + subnet, all in parallel |
| 2 (parallel) | `https://owhas.org` | 3 s | Runs alongside local scan for hybrid detection |
| 3 | Hybrid resolution | — | Both local + cloud up → hybrid mode |
| 4 | `https://owhas.org` | 5 s | Slow 4G retry |
| 5 | `http://owhas.org:5501` | 5 s | Direct HTTP fallback (port 443 blocked) |
| **6** | `https://owhas.org` | 5 s | **Final last-resort retry** before giving up |
| 7 | `http://192.168.137.1:5501` | — | Hardcoded fallback (no server found) |

Local LAN candidates (step 2):

| | URL | Scenario |
|---|---|---|
| | `http://10.50.1.5:5501` | University VLAN (ICTU_ATD) |
| | `http://192.168.137.1:5501` | Windows hotspot |
| | `http://192.168.43.1:5501` | Android hotspot |
| | `http://172.20.10.1:5501` | iOS hotspot |
| | `http://192.168.{0,1}.*:5501` | Full /24 subnet scan |
| | `http://10.0.0.*:5501` | 10.x subnet scan |

**Why cloud is checked first and last:** most sessions use `owhas.org` directly over mobile data or campus internet. Checking it first means online users get a result in ≤ 2 s without waiting for the local scan. Checking it last means a brief cloud hiccup at startup doesn't permanently fall through to the hardcoded hotspot default.

---

## 1a. Cloud URL vs HTTP Fallback — Key Differences

Both point to the same owhas.org server but behave very differently:

| | `https://owhas.org` (priority 5) | `http://owhas.org:5501` (priority 6) |
|---|---|---|
| **Protocol** | HTTPS (TLS encrypted) | Plain HTTP (unencrypted) |
| **Port** | 443 — the universal standard HTTPS port | 5501 — custom Node.js port, direct |
| **Routing** | Goes through a reverse proxy (Nginx) which terminates SSL and forwards to Node.js | Bypasses the proxy; hits Node.js directly |
| **Browser secure context** | ✅ Yes — enables webcam (`getUserMedia`), GPS (`geolocation`), Clipboard API | ❌ No — webcam and clipboard blocked by browser; GPS may also be refused |
| **Face scan on hotspot.html** | ✅ Fully works (webcam live view + multi-model analysis) | ❌ Camera unavailable; student must fall back to file picker on mobile |
| **Port blocking risk** | Very low — port 443 is open on virtually every network | Higher — some ISPs, corporate firewalls, or university networks block non-standard ports |
| **Detection order** | Tried in parallel with local scan (step 3), then retried at 5 s for slow 4G (step 4) | Last resort only — tried at step 5 after everything else has already failed |
| **When it's used** | Normal cloud/online mode | Only when port 443 is unreachable but port 5501 is somehow open |
| **`isOnline` flag** | `true` | `true` |

**Practical meaning:** if a student's browser ends up on `http://owhas.org:5501`, the webcam-based face scan will not work (the browser blocks `getUserMedia` on non-secure origins). The student will have to use their phone's native camera via the file picker instead. Everything else (PIN verify, registration, heartbeat) works fine.

---

## 2. Hybrid Mode

If **both** a local URL (VLAN or hotspot) **and** `owhas.org` respond, `isHybrid = true`.

In hybrid mode `AttendanceRecordNotifier.refreshRecords()` fetches from **both** servers and merges results by matricule — so students who typed `owhas.org` directly are included alongside hotspot registrations.

---

## 3. Two Types of Server Status Warnings

### `serverWarning` (SessionStateNotifier)
Set when the Node server is **not reachable at session-start** or after a failed retry.

- **Shown as:** red/orange `ServerWarningBanner` below the session header.
- **Trigger:** `pushSessionConfig` throws during `createSession` or `retryServerConnection`.
- **Effect:** Web registration (`hotspot.html`) is unavailable — students cannot connect via browser until resolved.
- **Fix:** Tap **Retry** → app calls `ServerConfig().reset()` + `detect()` + `pushSessionConfig()` again. On success the banner clears and the QR code refreshes.

### `serverError` (AttendanceRecordNotifier)
Set when a **record refresh poll** fails (server went down mid-session).

- **Shown as:** amber `SyncErrorBanner` — only visible when `serverWarning` is already `null` (i.e. server started fine but dropped later).
- **Trigger:** `fetchServerAttendees()` / `fetchServerStats()` throws inside `refreshRecords()`.
- **Effect:** Dashboard falls back to locally cached records (saved to SharedPreferences on the last successful fetch), so no attendance data is lost.
- **Fix:** Tap **Retry** → calls `refreshRecords()` again; clears on success.

---

## 4. Auto-Refresh Polling

`LecturerDashboardScreen` runs a `Timer.periodic` every **5 seconds** that calls:

```
refreshRecords(session)      ← fetch attendees from server, merge with local cache
refreshWifiDeviceCount()     ← scan active devices on the Wi-Fi subnet
```

If the session has passed its `endTime`, the timer ends the session automatically and navigates home.

---

## 5. Data Persistence During Server Outage

Every successful `refreshRecords()` call writes the fetched server records to **SharedPreferences** (`attendance_<sessionId>`) via `saveAttendanceRecordBatch()`. If the server drops:

1. The next poll fails → `serverError` is set → `SyncErrorBanner` appears.
2. The merge step still runs against the locally cached records.
3. The lecturer sees the last known attendance list uninterrupted.

Records are keyed by `matricule`, so the same student is never duplicated across local + server sources.

---

## 6. Reset / Teardown

On session end (`forceEndSession` or manual end), `ServerConfig` and the API service are reset:

- `_apiService.clearSession()` — clears the stored PIN/token.
- `ServerConfig().reset()` — clears `_detectedUrl` and `_isHybrid` so the next session re-detects the server fresh.
- `_serverWarning` is set to `null`.
