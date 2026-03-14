# Appendix 1 — Problem Formulation

---

## 1.1 Conceptualisations

### Initial Concept

The core idea is a compact, vehicle-mounted device built around a custom SoC that uses an external camera to continuously monitor the driver's face. When signs of drowsiness are detected — prolonged eye closure, excessive blinking, or head drooping — the system responds through three simultaneous channels: it sends an alert to the driver's smartphone via BLE (triggering an in-app notification and rerouting suggestions), it activates a wired external audible alarm mounted in the cabin to immediately wake the driver, and it publishes the detection event over WiFi via MQTT to a backend system where the fleet operator is notified of the occurrence. The system must operate with minimal latency across all three alert paths.

### Key Constraints Identified Early

- **Real-time performance:** Detection-to-alert latency must be low enough that the driver is warned before a dangerous situation develops.
- **Edge inference:** Processing must happen locally on the SoC to avoid dependency on cellular connectivity for detection.
- **Lighting variability:** The system must function at night and in low-light conditions, requiring built-in IR camera support.
- **Non-intrusive:** The system should not distract the driver or require interaction while driving.
- **Cross-platform mobile app:** The alert interface must work on both iOS and Android.
- **Fleet visibility:** Detection events must be forwarded to a backend system so fleet operators can monitor driver fatigue in real time.
- **Redundant alerting:** The system must not rely solely on the phone for driver alerting; a wired external alarm provides a hardware-level backup.
- **Cost:** The total hardware cost should remain feasible for consumer or fleet deployment.


## 1.2 Brainstorming

The team conducted brainstorming sessions to explore the design space across four major dimensions: hardware platform, ML approach, communication protocol, and mobile app framework. The following captures the ideas generated in each area.

### Hardware Platform Options

**Custom SoC with WiFi, BLE**
**Raspberry Pi 5**
**ESP32** 
**Smartphone-only (no external hardware)** 

### ML Model / Framework Options

**MediaPipe Face Mesh**
**Custom CNN (eye state classifier)**
**YOLO-Face + landmark regression**
**DeepStream pipeline (NVIDIA)**

### Communication Protocol Options

**MQTT (SoC → Backend)**
**Direct WebSocket (SoC → Backend)**
**BLE (SoC → Phone)**
**Wired GPIO signal (SoC → External alarm)**

### Mobile App Framework Options

**Flutter** 
**React Native** 
**Native (Swift + Kotlin)**

---

## 1.3 Decision Tables

The team used weighted decision matrices to evaluate alternatives across the four major design dimensions. Criteria were weighted based on project priorities (safety-critical real-time performance, development feasibility within two quarters, and cost).

### Decision Table 1: Hardware Platform

| Criteria (weight) | Custom SoC with WiFi, BLE | RPi 5 | ESP32 |
|--------------------|:---:|:---:|:---:|
| **ML inference speed (0.30)** | 5 | 2 | 1 |
| **Power efficiency (0.10)** | 3 | 4 | 5 |
| **Cost (0.15)** | 2 | 4 | 5 |
| **SDK / tooling (0.20)** | 5 | 4 | 2 |
| **Camera/sensor support (0.15)** | 5 | 4 | 2 |
| **Community / documentation (0.10)** | 4 | 5 | 4 |
| **Weighted Total** | **4.15** | **3.40** | **2.45** |

**Decision:** Custom SoC with WiFi, BLE — with GPU-accelerated inference component, which is critical for achieving real-time performance on a DNN-based detection pipeline. The integrated WiFi enables direct MQTT communication with the backend, while BLE provides a low-latency link to the driver's phone.

### Decision Table 2: SoC → Phone Communication Protocol

| Criteria (weight) | BLE | Direct WebSocket | MQTT via Phone |
|--------------------|:---:|:---:|:---:|
| **Latency (0.25)** | 5 | 4 | 3 |
| **Reliability (0.25)** | 4 | 3 | 3 |
| **Power efficiency (0.15)** | 5 | 2 | 2 |
| **Offline capability (0.15)** | 5 | 2 | 2 |
| **Implementation complexity (0.10)** | 3 | 4 | 2 |
| **Packet size suitability (0.10)** | 4 | 5 | 5 |
| **Weighted Total** | **4.40** | **3.15** | **2.55** |

**Decision:** BLE — offers low-latency, low-power, small-packet transfers ideal for sending drowsiness detection events from the SoC to the driver's phone without requiring an internet connection.

### Decision Table 3: SoC → Backend Communication Protocol

| Criteria (weight) | MQTT | HTTP POST | Direct WebSocket |
|--------------------|:---:|:---:|:---:|
| **Reliability (0.25)** | 5 | 4 | 3 |
| **Latency (0.20)** | 4 | 3 | 5 |
| **Data persistence (0.20)** | 5 | 3 | 2 |
| **Scalability (0.15)** | 5 | 3 | 2 |
| **Implementation complexity (0.10)** | 3 | 4 | 3 |
| **Offline resilience (0.10)** | 5 | 2 | 1 |
| **Weighted Total** | **4.55** | **3.25** | **2.80** |

**Decision:** MQTT — provides reliable, lightweight pub/sub messaging with QoS guarantees, well-suited for publishing detection events from the SoC over WiFi to the backend where fleet operators are notified.

### Decision Table 4: Mobile App Framework

| Criteria (weight) | Flutter | React Native | Native (Swift+Kotlin) |
|--------------------|:---:|:---:|:---:|
| **Cross-platform from single codebase (0.30)** | 5 | 4 | 1 |
| **Development speed (0.25)** | 5 | 4 | 2 |
| **Performance (0.15)** | 4 | 3 | 5 |
| **Team familiarity (0.20)** | 4 | 3 | 2 |
| **Library ecosystem for BLE (0.10)** | 4 | 4 | 5 |
| **Weighted Total** | **4.55** | **3.65** | **2.40** |

**Decision:** Flutter — delivers cross-platform support from a single Dart codebase with strong BLE and notification libraries, enabling both driver alerting and rerouting functionality.

### Decision Table 5: ML Model / Framework

| Criteria (weight) | MediaPipe + EAR | Custom CNN | YOLO-Face |
|--------------------|:---:|:---:|:---:|
| **Inference speed (0.30)** | 4 | 4 | 3 |
| **Accuracy (0.25)** | 4 | 3 | 3 |
| **Integration with SoC (0.20)** | 4 | 3 | 4 |
| **Development effort (0.15)** | 4 | 1 | 4 |
| **Documentation (0.10)** | 5 | 1 | 4 |
| **Weighted Total** | 4.10 | 2.80 | 3.45 |

**Decision:** MediaPipe Face Mesh with EAR (Eye Aspect Ratio) and head pose estimation — provides reliable, real-time detection of eye closure, excessive blinking, and head drooping with minimal computational overhead, making it well-suited for edge deployment on the SoC.

---

## 1.4 Morphological Chart

The morphological chart below maps each functional requirement of the system to the design alternatives considered, with the **selected option highlighted in bold**.

| Function | Option A | Option B | Option C | Option D |
|----------|----------|----------|----------|----------|
| **Compute platform** | **Custom SoC (WiFi + BLE)** | Raspberry Pi 5 | RPi + Coral TPU | ESP32 |
| **Camera type** | USB webcam (visible light) | **IR camera (night-capable)** | Stereo depth camera | Smartphone camera |
| **Face detection** | MediaPipe Face Detector | dlib HOG detector | YOLO-Face | Haar Cascades |
| **Drowsiness metrics** | EAR only | PERCLOS only | **EAR + head pose estimation** | Blink frequency only |
| **Fatigue classification** | Threshold-based (EAR < value) | **Temporal analysis (EAR + head pose over sliding window)** | CNN binary classifier | Hybrid (threshold + CNN) |
| **SoC → phone comm** | **BLE** | Direct WebSocket | HTTP POST | MQTT via phone |
| **SoC → backend comm** | **MQTT over WiFi** | HTTP POST | Direct WebSocket | None |
| **SoC → external alarm** | **Wired GPIO signal** | BLE to alarm module | WiFi-controlled relay | None |
| **Backend storage** | **PostgreSQL** | MongoDB | SQLite | Firebase Realtime DB |
| **Backend → fleet operator** | **WebSocket gateway** | FCM push | Polling (HTTP) | Server-Sent Events |
| **Mobile framework** | **Flutter** | React Native | Native iOS + Android | Kotlin Multiplatform |
| **App alert modality** | Visual popup only | **Audio alarm + vibration + visual** | Haptic wearable | — |
| **App rerouting** | **In-app rerouting suggestions** | External maps redirect | No rerouting | — |
| **External alarm type** | **Audible buzzer/speaker (wired)** | LED strobe | Seat vibration motor | — |
| **Power source** | **Vehicle 12V (via adapter)** | USB battery bank | Hardwired to OBD-II | Solar + battery |
| **Mounting** | Dashboard mount | **Visor/mirror mount** | A-pillar clip | Rearview mirror replacement |


The selected path through the morphological chart (bold entries) represents the team's final design: a custom SoC with integrated WiFi and BLE, paired with an IR camera, performing EAR-based and head-pose-based drowsiness detection over a sliding temporal window. When drowsiness is detected, the SoC simultaneously (1) sends an alert via BLE to a cross-platform Flutter app that notifies the driver with audio, vibration, and visual alerts and offers rerouting suggestions, (2) activates a wired external audible alarm in the cabin for immediate driver alerting, and (3) publishes the detection event via MQTT over WiFi to a backend that persists data in PostgreSQL and notifies the fleet operator through a WebSocket gateway.
