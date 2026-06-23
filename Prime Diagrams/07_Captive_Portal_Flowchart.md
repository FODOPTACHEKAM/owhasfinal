# Figure 4.7: Captive Portal Workflow

## Purpose
Shows the hotspot attendance workflow using captive portal auto-detection.

## Diagram Type
**Flowchart**

## What is a Captive Portal?
A captive portal is a mechanism where devices connecting to a Wi-Fi network without internet access are automatically redirected to a web page. In OwHAS, when students connect to the lecturer's hotspot, their devices detect "no internet" and automatically open a browser window pointing to the registration page — no QR scan or URL entry needed.

## Flow Steps

### Step 1: Connect to Hotspot
- **Actor:** Student
- **Action:** Student selects the lecturer's Wi-Fi hotspot from available networks
- **Network:** Hotspot SSID is announced by lecturer (e.g., "OwHAS-Session")
- **Result:** Device connects and receives local IP (192.168.x.x)

### Step 2: Captive Portal Detection
- **Actor:** Student's Device (OS-level)
- **Action:** Device OS (Android/iOS) performs connectivity check:
  - Android: Pings `connectivitycheck.gstatic.com`
  - iOS: Pings `captive.apple.com`
  - Windows: Pings `www.msftconnecttest.com`
- **Result:** No internet detected → OS triggers captive portal notification

### Step 3: Registration Page Opens
- **Actor:** Device browser
- **Action:** Browser automatically opens and redirects to:
  - `http://192.168.x.1:8080/hotspot.html`
- **Result:** Student sees the attendance registration form
- **Fallback:** If auto-redirect fails, student can manually open browser and navigate

### Step 4: Student Registers
- **Actor:** Student
- **Action:** Student completes the registration form:
  1. Enter session PIN (4-digit code)
  2. Enter name and matriculation number
  3. Capture face image
  4. Draw digital signature (optional)
  5. Click "Submit"

### Step 5: Attendance Saved
- **Actor:** Node.js Server
- **Action:** Server receives and processes the form:
  1. Validate session PIN
  2. Extract face descriptor (face-api.js)
  3. Check for duplicate faces
  4. Store attendance record with timestamp and device info
  5. Return success/failure response
- **Result:** Attendance recorded, student sees confirmation

## Flowchart Diagram
```
[●] Start
  |
  v
[Student: Select Hotspot Wi-Fi]
  |
  v
[Device: Connect to Network]
  |
  v
[OS: Connectivity Check]
  |
  v
◇ Internet Available?
  |No (Expected)        |Yes (Unexpected)
  v                     v
[Trigger Captive       [Student on wrong
 Portal Notification]   network → Reconnect]
  |
  v
◇ Auto-Redirect Works?
  |Yes                  |No
  v                     v
[Browser Opens         [Show notification
 Registration Page]     "Sign in to network"]
  |                     |
  |                     v
  |                   [Student taps notification]
  |                     |
  +--------+------------+
           |
           v
  [Registration Form Displayed]
    |
    v
  [Enter PIN]
    |
    v
  ◇ PIN Valid?
    |Yes            |No
    v               v
  [Fill Form]    [Error → Retry]
    |
    v
  [Capture Face]
    |
    v
  [Submit Registration]
    |
    v
  [Server: Process & Save]
    |
    v
  ◇ Success?
    |Yes            |No
    v               v
  [Show            [Show Error
   Confirmation]    → Retry]
    |
    v
  [⊙] End
```

## Captive Portal Behavior by Platform

| Platform | Detection Method | Behavior |
|----------|-----------------|----------|
| Android | HTTP check to Google | Shows "Sign in to Wi-Fi" notification |
| iOS | HTTP check to Apple | Opens mini-browser sheet automatically |
| Windows | HTTP check to Microsoft | Shows "Action needed" in taskbar |
| macOS | HTTP check to Apple | Opens captive portal window |

## Advantages of Captive Portal Approach
1. **Zero student effort** — page opens automatically
2. **No app installation** — works in any browser
3. **Physical proximity proof** — must be on the hotspot to access
4. **Works offline** — no internet required

## Drawing Instructions
1. Start with student connecting to Wi-Fi
2. Show OS-level detection step
3. Branch for auto-redirect success/failure
4. Continue through registration form
5. Show server processing and confirmation
6. Use standard flowchart symbols

## Tools
- Draw.io / diagrams.net
- Lucidchart
- Microsoft Visio
