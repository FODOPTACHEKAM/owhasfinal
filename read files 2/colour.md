# Server Status Colours

The server status banner on the home screen uses colour-coded indicators to show the current connection state.

| Status | Colour | Hex Code | Icon | Label | When |
|--------|--------|----------|------|-------|------|
| Cloud Server | Green | `#27AE60` | Cloud | `Cloud Server · owhas.org` | Connected to the online HTTPS endpoint (owhas.org) |
| Wi-Fi Server | Red | `#E53935` | Wi-Fi | `Wi-Fi Server · <IP>` | Connected to a local hotspot or VLAN server (e.g. 192.168.137.1) |
| Hybrid Network | Purple | `#7C3AED` | Cell+Wi-Fi | `Hybrid Network · <IP> + cloud` | Both local server and cloud are reachable simultaneously |
| Workers Network | Black | `#212121` | Building | `Workers Network · 10.13.14.164` | Connected to the Workers Wi-Fi SSID (server at 10.13.14.164) |
| No Server Found | Orange | `#E67E22` | Wi-Fi Off | `No Server Found` | No server reachable on any network |
| Detecting | Grey | `#8E9AAB` | Radar | `Detecting…` | Server detection is in progress |

## How Detection Works

1. **Workers VLAN first** — checks `10.13.14.164` and `atd.ictu.loc` before anything else (800ms). If found, returns immediately as Workers Network (black) — cloud is never checked, so internet on the Workers SSID is ignored.
2. Cloud check (owhas.org, 2s timeout) — fastest path for most sessions
3. Local LAN scan in parallel: fixed gateway IPs + full subnet (800ms timeout)
4. If both local + cloud respond — Hybrid (purple)
5. If only local responds — Wi-Fi Server (red)
6. If only cloud responds — Cloud Server (green)
7. If nothing responds — No Server Found (orange)

## Files

- Banner UI: `lib/features/home/widgets/home_ui_components.dart`
- Status enum + notifier: `lib/features/home/notifiers/server_status_notifier.dart`
- Server detection: `lib/services/server_config.dart`
