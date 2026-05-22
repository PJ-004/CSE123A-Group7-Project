# ML Model — SleepyDrive Drowsiness Detection Pipeline

This document describes the trained AI model and detection pipeline used in the SleepyDrive system.

---

## 1. Model Overview

The SleepyDrive detection pipeline uses a **custom-optimized, two-stage face analysis model** that runs entirely on-device (edge inference). No video frames or images are ever sent to the cloud.

| Property | Value |
|----------|-------|
| **Model Name** | `facenet_vpruned_quantized_v2.0.1` |
| **Architecture** | Two-stage: Face Detection (BlazeFace SSD) → Face Landmarks (FaceMesh 478-point) |
| **Optimization** | V-pruned (structured pruning) + quantized (FP16) |
| **Model Size** | 3.6 MB (`.task` bundle) |
| **Inference Speed** | 30+ FPS real-time on Jetson Orin Nano; target 30 FPS on custom SoC |
| **Input** | RGB camera frames (any resolution, resized internally) |
| **Output** | 478 facial landmarks with 3D coordinates (x, y, z) |

---

## 2. Detection Pipeline

### Stage 1 — Face Detection (BlazeFace SSD)

The first stage detects whether a face is present in the camera frame and localizes it.

- **Architecture:** Single Shot Detector (SSD) with BlazeFace anchors
- **Input:** 128×128 RGB image (resized from camera frame)
- **Output:** Bounding box coordinates + 6 facial keypoints (eyes, nose, mouth, ears) + confidence score
- **Anchor Generation:** 896 pre-computed SSD anchors across 4 stride layers (8, 16, 16, 16)
- **Post-processing:** Weighted Non-Maximum Suppression (NMS) — overlapping detections are blended by score rather than discarded, improving stability
- **Score threshold:** 0.5 (face must have ≥50% confidence to proceed to Stage 2)

### Stage 2 — Face Landmarks (FaceMesh)

The second stage extracts 478 precise facial landmarks from the detected face region.

- **Input:** 256×256 affine-aligned face crop (rotated and scaled from the Stage 1 bounding box)
- **Output:** 478 landmarks, each with normalized (x, y, z) coordinates
- **Landmarks used for drowsiness:**
  - **Eye landmarks** (6 per eye): Used to compute the Eye Aspect Ratio (EAR)
  - **Nose tip** (landmark 1), **forehead** (landmark 10), **chin** (landmark 152): Used for head vertical position tracking

### Processing Pipeline

```
Camera Frame (640×480 @ 30 FPS)
    │
    ▼
┌──────────────────────┐
│ GPU Preprocessing    │  BGR → RGB conversion (CUDA-accelerated when available)
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Stage 1: BlazeFace   │  128×128 input → bounding box + keypoints
│ Face Detection       │  SSD + Weighted NMS
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Affine Crop & Align  │  Rotate + scale face region → 256×256
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Stage 2: FaceMesh    │  256×256 input → 478 landmarks (x, y, z)
│ Landmark Regression  │  Reverse-projected to original image coords
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Drowsiness Analysis  │  EAR computation + head pose estimation
│ (see §3)             │  Temporal analysis over sliding window
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Alert Dispatch       │  Alarm (local) + BLE (phone) + MQTT (cloud)
└──────────────────────┘
```

---

## 3. Drowsiness Detection Algorithm

### 3.1 Eye Aspect Ratio (EAR)

The primary drowsiness metric is the **Eye Aspect Ratio (EAR)**, computed from 6 landmark points per eye:

```
        P2    P3
       /        \
P1 ──────────────── P4
       \        /
        P6    P5

EAR = (|P2 - P6| + |P3 - P5|) / (2 × |P1 - P4|)
```

| Parameter | Value | Description |
|-----------|-------|-------------|
| `EAR_THRESHOLD` | 0.21 | Below this value = eyes considered closed |
| `EAR_CONSEC_FRAMES` | 2 | Consecutive closed frames to register a blink |
| `DROWSY_TIME_THRESHOLD` | 1.5 seconds | Continuous closure beyond this = drowsiness event |

**MediaPipe Landmark Indices Used:**
- Left eye: [33, 160, 158, 133, 153, 144]
- Right eye: [362, 385, 387, 263, 373, 380]

The final EAR is the average of left and right eyes: `EAR = (left_EAR + right_EAR) / 2.0`

### 3.2 Head Vertical Position (Attention Tracking)

A secondary detection monitors head drooping, which commonly occurs when a driver begins falling asleep.

- **Measurement:** Nose tip position (landmark 1) relative to forehead-chin range (landmarks 10 and 152), normalized to be scale-invariant.
- **Baseline Calibration:** During the first ~3 seconds (90 frames at 30 FPS), the system builds a baseline of the driver's normal head position using an exponential moving average (EMA, α = 0.3).
- **Deviation Detection:** If the smoothed head position deviates from baseline by more than `HEAD_DEVIATION_THRESHOLD` (0.06 normalized units) for longer than `HEAD_INATTEN_TIME_THRESH` (2.0 seconds), a head inattention event is triggered.

### 3.3 Event Classification

| Event Type | Trigger Condition | Alert Severity |
|------------|------------------|----------------|
| **Blink** | EAR < 0.21 for ≥ 2 consecutive frames, then recovers | Logged (no alert) |
| **Micro Sleep** | EAR < 0.21 continuously for ≥ 1.5 seconds | Critical — alarm + BLE + MQTT |
| **Sleep Event** | EAR < 0.21 continuously for ≥ 3.0 seconds | Critical (escalated) — louder alarm |
| **Head Inattention** | Head deviates > 0.06 from baseline for ≥ 2.0 seconds | High — alarm + BLE + MQTT |
| **No Face Detected** | No face landmarks returned by Stage 1 | Warning — "Driver not detected" |

---

## 4. Custom Model Optimization

### 4.1 Why a Custom Model

The stock MediaPipe face landmarker model is designed for general-purpose use on mobile devices. For our use case (single driver, fixed camera angle, real-time safety-critical inference on an edge device), we applied the following optimizations:

### 4.2 Optimization Techniques Applied

| Technique | What It Does | Impact |
|-----------|-------------|--------|
| **V-Pruning (Structured Pruning)** | Removes entire filter channels from convolutional layers that contribute least to the output | Reduces model size and inference time while preserving accuracy on our target domain |
| **FP16 Quantization** | Converts model weights from 32-bit floating point to 16-bit | 2× reduction in model memory footprint, faster inference on GPU (which has native FP16 support) |
| **TensorRT Acceleration** | Converts ONNX model graphs into optimized TensorRT engines with fused operations | 2-4× speedup over CPU inference; uses GPU tensor cores |

### 4.3 TensorRT Custom Pipeline

In addition to the optimized `.task` model, we built a fully custom **TensorRT-accelerated inference pipeline** (`module_tensorrt_landmarker.py`) that:

1. **Extracts** the face detector and face landmarks models from the MediaPipe `.task` bundle into standalone ONNX files (`face_detector.onnx`, `face_landmarks_detector.onnx`).
2. **Loads** both models into ONNX Runtime with TensorRT Execution Provider (FP16 enabled, 2 GB workspace).
3. **Implements** the full BlazeFace SSD decoding pipeline (anchor generation, box decoding, weighted NMS) in NumPy for maximum control.
4. **Implements** affine face crop and alignment to prepare the 256×256 landmark input.
5. **Reverse-projects** landmarks from crop space back to original image coordinates.
6. **Outputs** `MockDetectionResult` objects that are drop-in compatible with the existing EAR and head-pose code.

### 4.4 Accuracy Validation

We validate the custom pipeline against the standard MediaPipe pipeline using a recorded test video (`compare_accuracy.py`):

| Metric | Description |
|--------|-------------|
| **Average EAR (MediaPipe)** | Baseline EAR values from standard CPU pipeline |
| **Average EAR (TensorRT)** | EAR values from our GPU-accelerated pipeline |
| **Mean Absolute Error** | Average difference in EAR between the two pipelines |
| **Correlation** | Pearson correlation coefficient (target: > 0.95) |
| **Detection Rate** | Percentage of frames where each pipeline detected a face |

The custom pipeline achieves near-identical accuracy to the standard MediaPipe pipeline while running significantly faster on the Jetson GPU.

---

## 5. Model Versioning

| Version | Changes |
|---------|---------|
| `v1.0` | Baseline MediaPipe face landmarker (stock model, CPU only) |
| `v2.0` | V-pruned model with structured channel pruning |
| `v2.0.1` | V-pruned + FP16 quantization (current production model) |

The model file is stored at: `model/facenet_vpruned_quantized_v2.0.1/face_landmarker.task` (3.6 MB)

<div style="page-break-after: always;"></div>
