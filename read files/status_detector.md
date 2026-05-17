# How the Server Status Detector Works

## Overview

The status detector answers one question every time the app opens:
**"Which server can I reach, and how?"**

It runs in two layers — one that finds the server URL at startup
(deep detection), and one that watches the result and drives the UI banner.

---

## Layer 1 — ServerConfig (URL Detection)

File: `lib/services/server_config.dart`

This is a **singleton** that runs once at startup inside `main()`:

```dart
await ServerConfig().detect();
```

### What it does

Detection runs in a **background isolate** via Flutter's `compute()`.
This means it never blocks the UI thread — the splash screen stays
smooth while hundreds of network pings fire in parallel.

### Detection order (priority)

```
1. Fixed hotspot candidates (parallel, 800 ms timeout each)
   ├── 192.168.137.1:5501   ← Windows Mobile Hotspot
   ├── 10.0.0.1:5501
   ├── 192.168.43.1:5501    ← Android hotspot
   ├── 172.20.10.1:5501     ← iOS hotspot
   └── 192.168.50.1:5501

2. Full subnet scan — ALL run in parallel (800 ms timeout each)
   ├── 192.168.0.1–254:5501
   ├── 192.168.1.1–254:5501
   └── 10.0.0.1–254:5501

3. Emulator loopback
   └── 10.0.2.2:5501

4. Cloud server (5-second timeout — slower because internet)
   ├── http://owhas.org:5501    ← tried first (direct HTTP, no proxy)
   └── https://owhas.org        ← tried second (reverse proxy)

5. Fallback (no server found)
   └── http://192.168.137.1:5501  (stored but marked unreachable)
```

Each candidate is pinged at `<url>/ping` — a `200 OK` response means
the server is there. Because all local candidates run in parallel, the
total wait for local detection is ~800 ms regardless of how many IPs
are scanned.

### Result

After detection, two values are cached in the singleton:

| Field | Meaning |
|---|---|
| `_detectedUrl` | The full base URL of the found server |
| `_isOnline` | `true` if cloud was found, `false` if local hotspot |

These are exposed as `ServerConfig().baseUrl` and `ServerConfig().isOnline`.
Every API call in the app reads `baseUrl` from here.

---

## Layer 2 — ServerStatusNotifier (Live Status)

File: `lib/features/home/notifiers/server_status_notifier.dart`

This is a `ChangeNotifier` registered as a Provider in `main.dart`.
It wraps the detection result in a UI-friendly enum:

```dart
enum ServerConnectionStatus { checking, cloud, wifi, none }
```

### Initialization

Called right after `ServerConfig().detect()` completes:

```dart
ServerStatusNotifier()..initialize()
```

`initialize()` calls `_updateStatus()` which:

1. **Pings the detected URL** via `ApiService().pingServer()`
   - Success + `isOnline == true`  → status = `cloud`
   - Success + `isOnline == false` → status = `wifi`

2. **If ping fails** (e.g. phone switched to mobile data after detection),
   tries both cloud URLs directly as a second chance:
   - `http://owhas.org:5501/ping`
   - `https://owhas.org/ping`
   - Either returns 200 → status = `cloud`

3. **If both fail** → status = `none`

### Refresh

The banner has a refresh button. Tapping it calls `notifier.refresh()`:

```
reset ServerConfig cache
  → re-run full detection from scratch
    → re-ping result
      → update status + notify UI
```

This lets students recover if they switch networks (hotspot → mobile data
or vice versa) without restarting the app.

---

## Layer 3 — ServerStatusBanner (UI)

File: `lib/features/home/widgets/home_ui_components.dart`

A `Consumer<ServerStatusNotifier>` that reacts to every `notifyListeners()` call.

### What each status shows

| Status | Color | Icon | Label | Sub-label |
|---|---|---|---|---|
| `checking` | Grey | radar | Detecting… | — (spinner shown) |
| `cloud` | Green | cloud_done | Cloud Server | owhas.org |
| `wifi` | Navy | wifi | Wi-Fi Server | detected IP |
| `none` | Orange | wifi_off | No Server Found | Start server.js and reconnect |

### Layout

```
[ dot ]  [ icon ]  Label  ·  sub-label  [ refresh / spinner ]
```

- The dot is a 6×6 px circle — dimmed when checking, solid otherwise.
- The refresh icon uses `GestureDetector` with extra padding so the
  tap area is usable without making the visual large.
- While `checking`, the refresh icon is replaced by a `CircularProgressIndicator`.

---

## Full Data Flow

```
App starts
  │
  ├─ main() → ServerConfig().detect()   [background isolate, ~800 ms local / ~5 s cloud]
  │              stores baseUrl + isOnline
  │
  ├─ runApp() → MultiProvider
  │              └─ ServerStatusNotifier()..initialize()
  │                   └─ ping baseUrl
  │                        ├─ OK  → emit cloud / wifi
  │                        ├─ FAIL → try owhas.org directly
  │                        │          ├─ OK  → emit cloud
  │                        │          └─ FAIL → emit none
  │
  └─ HomeScreen renders ServerStatusBanner
       └─ Consumer<ServerStatusNotifier> reacts to every status change
            └─ shows color / icon / label matching current status

User taps refresh
  └─ notifier.refresh()
       └─ ServerConfig().reset() + detect() + _updateStatus()
            └─ banner updates in real time (checking → result)
```

---

## Why Two Separate Layers

`ServerConfig` is responsible for finding the URL — it is shared by
every part of the app (API calls, QR code generation, etc.).

`ServerStatusNotifier` is responsible only for displaying a live status
to the user. It re-pings independently so the banner stays accurate
even if the user switches networks after detection has already run.
Keeping them separate means a failed ping only affects the banner,
not the cached URL used by the rest of the app.
