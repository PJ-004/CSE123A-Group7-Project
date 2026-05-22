# SleepyDrive — User Manual

---

## What's in the Box

Your SleepyDrive package includes:

| Item | Description |
|------|-------------|
| SleepyDrive Device | The main unit with built-in IR camera, alarm speaker, and wireless radios |
| Visor Mount Kit | Adjustable clip for mounting the device on the sun visor or rearview mirror |
| 12V Vehicle Power Adapter | Cigarette lighter / accessory port adapter with 6 ft cable |
| Quick Start Card | Printed summary of these setup instructions |

---

## Part 1 — Driver Setup Guide

### Step 1: Install the Device in Your Truck

1. **Mount the device** on your sun visor or rearview mirror using the included visor mount clip. Position it so the camera lens points toward the driver's face.
2. **Plug the power adapter** into your vehicle's 12V accessory port (cigarette lighter). Route the cable neatly along the windshield edge.
3. **Power on.** The device starts automatically when it receives power. A steady green LED indicates that the device has booted and is ready. No buttons to press, no code to run.

> **Tip:** Position the device so the camera has a clear view of your face from roughly arm's length away. Avoid mounting it where the sun visor blocks the lens when flipped down.

### Step 2: Download the BLINK App

1. Download **BLINK** from the App Store (iOS) or Google Play Store (Android).
2. Open the app and tap **Create Account**.
3. Enter your email address and create a password.
4. On the role selection screen, tap **Driver**.
5. Enter your **display name** (this is what your fleet operator sees on their dashboard).

### Step 3: Join Your Fleet

Your fleet operator will provide you with an **8-character invite code** (for example, `A3B7K9X2`).

1. In the BLINK app, go to **Settings → Join Fleet**.
2. Enter the invite code and tap **Join**.
3. You are now connected to your fleet. Your operator can see your safety status on their dashboard.

### Step 4: Pair with the SleepyDrive Device

1. Make sure Bluetooth is enabled on your phone.
2. Open the BLINK app and go to the **Live Monitor** screen.
3. The app automatically scans for a nearby SleepyDrive device.
4. Connection status will change: **Scanning…** → **Connecting…** → **Connected**.
5. Once connected, a green Bluetooth icon appears in the app header.

> **Troubleshooting:** If the app cannot find the device, make sure the device is powered on (green LED), your phone's Bluetooth is on, and you are within ~30 feet of the device.

### Step 5: Drive

Once paired, the system is fully automatic:

- **When you are driving normally:** The Live Monitor screen shows your status as **SAFE** with a low fatigue risk percentage.
- **When drowsiness is detected:** You will receive:
  - An **audible alarm** from the device's built-in speaker in the truck cab.
  - A **phone alert** (vibration + on-screen notification) via Bluetooth.
  - A suggestion to **find a nearby rest stop** displayed in the app with directions.
- **If you ignore the warning:** The alarm escalates with increased volume and longer duration. Your fleet operator is also notified in real time.

### Understanding Alert Levels

| Level | What It Means | What Happens |
|-------|--------------|--------------|
| **SAFE** | Eyes open, head forward, alert | No action needed |
| **WARNING** | Eyes closed for ~1.5 seconds (micro sleep detected) | Short alarm + phone notification |
| **DANGER** | Eyes closed for 3+ seconds (sleep event detected) | Loud continuous alarm + phone alert + fleet operator notified |

### Offline Safety

The SleepyDrive device protects you **even without cell service or internet**:

- The built-in alarm sounds immediately regardless of connectivity.
- If your phone is paired via Bluetooth, you still get phone alerts (Bluetooth works without internet).
- When connectivity returns, any missed events are automatically sent to your fleet operator.

---

## Part 2 — Fleet Operator Setup Guide

### Step 1: Create Your Operator Account

1. Download the **BLINK** app or navigate to the BLINK web dashboard.
2. Tap **Create Account** and enter your email and password.
3. On the role selection screen, select **Fleet Operator**.
4. A fleet is automatically created for you with a unique **invite code** (for example, `A3B7K9X2`).

### Step 2: Add Drivers to Your Fleet

1. Go to **Fleet Settings** in the app or dashboard.
2. Copy your **invite code** and share it with your drivers (via text, email, or printed card).
3. When a driver enters your code in their BLINK app, they automatically appear on your dashboard.

> **Note:** You can remove a driver from your fleet at any time from the Fleet Settings screen.

### Step 3: Install Devices in Your Trucks

For each truck in your fleet:

1. Mount the SleepyDrive device using the visor mount kit.
2. Plug in the 12V power adapter.
3. The device powers on automatically and connects to the SleepyDrive cloud within seconds.
4. Each device has a unique device ID printed on the bottom label. Drivers associate themselves with a device through the app.

### Step 4: Monitor Your Fleet

The Fleet Operator Dashboard shows:

| Information | Description |
|-------------|-------------|
| **Driver List** | All drivers in your fleet with their current status |
| **Online / Offline** | Whether each device is currently active (heartbeat every 10 seconds) |
| **Fatigue Risk %** | Real-time fatigue risk level for each driver |
| **Alert History** | Complete log of all drowsiness events with timestamps |
| **Last Seen** | When the device last reported its status |

#### Real-Time Alerts

When any driver in your fleet triggers a drowsiness event:

1. Your dashboard highlights the driver in red.
2. An alert notification appears with the driver's name, event type, and timestamp.
3. The alert is logged in the driver's history for later review.

#### Driver Safety Trends

Use the alert history to identify:

- Drivers who frequently experience fatigue (may need schedule adjustments).
- Times of day when fatigue events are most common.
- Routes that correlate with higher drowsiness rates.

### Multi-Truck Operations

Each truck has its own SleepyDrive device with a unique identity. The system scales automatically:

- All devices report to the same cloud backend.
- The dashboard shows all drivers in your fleet simultaneously.
- Each driver's phone pairs with the device in their truck via Bluetooth (1:1 pairing).
- If drivers rotate between trucks, their phone simply re-pairs with the nearest SleepyDrive device.

---

## Part 3 — Frequently Asked Questions

**Q: Does the driver need to do anything each time they start a shift?**
A: No. The device starts automatically when the truck's ignition turns on (or when the 12V port is powered). The phone app auto-reconnects to the device via Bluetooth. The driver just drives.

**Q: What happens if my phone battery dies?**
A: The device's built-in alarm still sounds in the truck cab. The alarm is wired directly to the device and does not depend on the phone.

**Q: Does the system record video or store images of the driver?**
A: No. The AI model processes video frames in real time on the device itself. No video or images are stored, transmitted, or uploaded. Only alert events (text-based: "drowsiness detected at 3:42 PM") are sent to the cloud.

**Q: How far away can the Bluetooth connection work?**
A: Bluetooth Low Energy (BLE) works reliably within approximately 30 feet (10 meters). Inside a truck cab, this is always sufficient.

**Q: Can I use the system in my personal vehicle?**
A: Yes. The device mounts on any visor or mirror and uses a standard 12V power adapter. For personal use, you do not need a fleet operator — the driver app works standalone.

**Q: What if the camera cannot see my face (sunglasses, hat, mask)?**
A: The system will display "Driver not detected" on the app. Standard sunglasses generally do not affect detection. Full face coverings or very dark tinted lenses may reduce accuracy.

**Q: Does the device work at night?**
A: Yes. The device includes an infrared (IR) camera that operates in complete darkness.

<div style="page-break-after: always;"></div>
