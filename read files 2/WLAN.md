# WLAN Deployment Guide — OwHAS on School Wi-Fi

This document explains how to move the OwHAS Node.js backend from the lecturer's personal
hotspot onto the school's existing WLAN (campus Wi-Fi network, e.g. **ICTU_ATD**),
so that student phones connect through the institutional access point instead of the
lecturer's phone or laptop hotspot.

---

## How the Two Modes Differ

| Aspect | Hotspot mode (current) | WLAN / VLAN mode (this guide) |
|---|---|---|
| Network | Lecturer's phone or laptop creates its own Wi-Fi | School's existing campus Wi-Fi |
| Server IP | Auto-detected (192.168.137.1 / 192.168.43.1, etc.) | Fixed IP assigned by IT (e.g. `10.50.1.5`) |
| DHCP | Windows / Android handles it | Server optionally runs its own DHCP, OR IT configures DHCP option 6 |
| Students connect to | Lecturer's hotspot SSID | Normal school Wi-Fi SSID |
| Captive portal | Automatic on hotspot | Works via DNS redirect if IT cooperates, OR students type the IP manually |
| `SERVER_IP` in `server.js` | `null` | `'10.50.1.5'` (your actual fixed IP) |

---

## Step 1 — Request a Fixed IP from the School IT Department

The server must have a predictable, stable IP address so the Flutter app can find it
without scanning the entire subnet every time.

Contact the IT department and ask for:

1. **A reserved (static) IP address** on the campus WLAN for the lecturer's laptop.
   - Typical range: `10.50.x.x`, `172.16.x.x`, or `192.168.x.x` depending on the school's scheme.
   - Example: `10.50.1.5`
2. **Inbound TCP port 5501 unblocked** on the campus firewall/ACL for that IP so
   student phones can reach the server.
3. *(Optional but ideal)* **DHCP option 6 (DNS server)** set to the server's IP on the
   classroom VLAN. This makes the captive portal pop up automatically when students join the Wi-Fi.
   If IT cannot do this, students either type the IP or scan the QR code — both still work.

---

## Step 2 — Configure the Server (`backend/server.js`)

Open [backend/server.js](backend/server.js) and find the one constant you need to change:

```js
// Line ~75
const SERVER_IP = null;   // ← HOTSPOT MODE (current)
```

Change it to your fixed IP:

```js
const SERVER_IP = '10.50.1.5';   // ← VLAN MODE — replace with your actual IP
```

**That is the only required change.** When `SERVER_IP` is set:

- The server uses the fixed IP for all URL generation and logging.
- Browser auto-open is skipped (the server runs headless).
- The DHCP server starts on port 67 and advertises the server's IP as the DNS server,
  so connecting phones discover the captive portal automatically.

---

## Step 3 — Install the DHCP Dependency

The built-in DHCP server (for VLAN mode) requires one extra npm package that is not
included in the default install:

```powershell
cd backend
npm install dhcp
```

If IT has already configured DHCP option 6 on the school side, this step is optional —
the server will log a warning if the package is missing but will still run normally.

---

## Step 4 — Configure the Flutter App (`lib/services/server_config.dart`)

Open [lib/services/server_config.dart](lib/services/server_config.dart) and find the
`fixedCandidates` list inside `_detectServerInBackground` (around line 43):

```dart
final fixedCandidates = <String>[
  // 'http://10.50.1.5:5501',   // ← University VLAN fixed IP (uncomment + edit when deployed)
  'http://192.168.137.1:5501',  // Windows Mobile Hotspot
  ...
];
```

Uncomment and edit the VLAN line with your actual IP:

```dart
final fixedCandidates = <String>[
  'http://10.50.1.5:5501',      // ← University VLAN (your fixed IP)
  'http://192.168.137.1:5501',  // Windows Mobile Hotspot
  ...
];
```

This puts the VLAN IP at the top of the probe list so the app finds the server instantly
at startup instead of scanning hundreds of subnet addresses first.

Rebuild the APK after making this change:

```powershell
flutter build apk --release
```

---

## Step 5 — Run the Server with Administrator Privileges

On the school Wi-Fi, the server needs to open ports 53 (DNS), 67 (DHCP), and 80
(captive-portal redirect) — all of which require elevated privileges on Windows.

The simplest way is to right-click your terminal and **Run as Administrator**, then:

```powershell
cd backend
node server.js
```

Or create a batch file (`start-server.bat`) in the `backend/` folder:

```bat
@echo off
node server.js
pause
```

Right-click `start-server.bat` → **Run as administrator** before each lecture.

When the server starts you should see in the console:

```
[MODE]   HTTP only - no SSL
[HOST]   0.0.0.0:5501 (listening on all interfaces)
[HOTSPOT] Primary IP: 10.50.1.5
[DNS]    Listening on 10.50.1.5:53
[DHCP]   Serving 10.50.1.10–10.50.1.200   DNS=10.50.1.5
[HTTP80] Captive portal active on :80
```

---

## How It Works End-to-End (VLAN Mode)

```
Student phone
     │
     │ 1. Connects to school Wi-Fi (ICTU_ATD)
     │
     ▼
DHCP handshake
     │  Server assigns IP to phone AND sets DNS = 10.50.1.5
     │  (or IT's DHCP does this if they configured option 6)
     │
     ▼
Phone's OS probes for captive portal
  GET /generate_204   (Android)
  GET /hotspot-detect.html  (iOS)
     │
     │ Server (port 80) returns 302 → http://10.50.1.5:5501/public/hotspot.html
     │
     ▼
"Sign in to network" notification appears on phone
     │
     ▼
Student taps notification → browser opens attendance web page automatically
     │
     ▼
Student enters PIN (from classroom poster or QR code), takes selfie, registers
     │
     ▼
Flutter app (lecturer's phone/laptop) polls /api/attendees and shows student as registered
```

If the captive portal auto-popup does not work (IT did not configure DHCP option 6 and
the `dhcp` npm package is not installed), students can still register by:

- Scanning the QR code displayed in the lecturer's Flutter app, **or**
- Typing `http://10.50.1.5` directly into Chrome (port 80 redirects to the attendance page).

---

## Firewall Rules

The server automatically adds Windows Firewall inbound rules on startup for ports
5501 (TCP), 53 (UDP), 67 (UDP), and 5353 (UDP). If the auto-add fails (not running as
Administrator), add them manually:

```powershell
# Run in an elevated PowerShell
netsh advfirewall firewall add rule name="OwHAS 5501" dir=in action=allow protocol=TCP localport=5501 profile=any
netsh advfirewall firewall add rule name="OwHAS DNS 53" dir=in action=allow protocol=UDP localport=53 profile=any
netsh advfirewall firewall add rule name="OwHAS DHCP 67" dir=in action=allow protocol=UDP localport=67 profile=any
netsh advfirewall firewall add rule name="OwHAS mDNS 5353" dir=in action=allow protocol=UDP localport=5353 profile=any
```

Also verify that **Windows Defender Firewall** is not blocking `node.exe` for the
"Public networks" profile — school networks are usually classified as Public by Windows.

---

## Verifying the Deployment

### From the lecturer's laptop

```powershell
curl http://10.50.1.5:5501/ping
# Expected: {"status":"ok"}
```

### From a student's phone (same Wi-Fi)

Open Chrome and navigate to `http://10.50.1.5` (no port needed — port 80 redirects).
The OwHAS registration page should load.

### From the Flutter app

The home screen shows a connection chip. After the app starts it should show
**Wi-Fi** (local server found). If it still shows **None**, tap the Refresh button on
the home screen — this re-runs `ServerConfig.detect()` which now has the VLAN IP at
the top of its probe list.

---

## Switching Back to Hotspot Mode

Set the constant back to `null` and restart:

```js
const SERVER_IP = null;   // hotspot mode restored
```

No other changes needed — `detectHotspotIP()` takes over automatically.

---

## Summary of All Changes Required

| File | What to change |
|---|---|
| `backend/server.js` line ~75 | `SERVER_IP = null` → `SERVER_IP = '10.50.1.5'` |
| `lib/services/server_config.dart` line ~46 | Uncomment the VLAN candidate IP line |
| `backend/` (terminal) | Run `npm install dhcp` once |
| Deployment | Always run `node server.js` as Administrator |
| APK | Rebuild with `flutter build apk --release` after editing `server_config.dart` |
