<div align="center">
  <h1>📸 FrameIQ</h1>
  <p><strong>Your AI-Powered Real-Time Photography Coach</strong></p>

  [![Flutter Version](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter)](https://flutter.dev/)
  [![Dart Version](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart)](https://dart.dev/)
  [![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
  [![State Management](https://img.shields.io/badge/Riverpod-2.x-1099f7)](https://riverpod.dev/)

  <p>
    An intelligent mobile camera app that acts as your personal photography mentor. FrameIQ detects scenes, analyzes subjects, and overlays dynamic composition guides at 60fps—so you can capture the perfect shot every time.
  </p>
</div>

---

## ✨ Why FrameIQ?

Photography is an art, but it relies heavily on fundamental rules of composition. FrameIQ takes the guesswork out of taking photos. The app opens your camera and **automatically overlays composition guides** directly on your live camera feed. 

It also detects the scene (e.g., portrait, landscape, food) and provides coaching suggestions in real-time, such as angle corrections, posture tips, and a live composition score. You don't need to tweak settings—just open the app, and the AI guides you to the best possible frame.

---

## 🚀 Core Features

### 📐 Dynamic Composition Overlays
FrameIQ renders highly-optimized overlays directly via `CustomPaint` on top of the camera stream.
- **Rule of Thirds**: For portraits, landscapes, and auto modes.
- **Golden Spiral**: Fibonacci spiral guiding the eye to the focal point (perfect for macros).
- **Symmetry**: Center axis crosshairs designed for architectural shots.
- **Leading Lines**: Vanishing point markers for street photography.
- **Diagonal & Golden Triangle**: For capturing dynamic action.
- **Center Frame**: Concentric targets perfectly suited for food photography.

### 🧠 Real-Time AI Scene & Subject Detection
Powered by Google ML Kit, running efficiently in the background without dropping frames:
- **Scene Classification**: Automatically identifies 10+ scene types and adapts the composition overlay to match.
- **Face Coach Service**: Detects facial framing, analyzing roll/yaw angles and distance to provide instant warnings (e.g., *"Tilt head left to level up"* or *"Too close—back up"*).

### ⚖️ Gyroscopic Horizon Coach
Utilizes the device's accelerometer to compute the gravity vector. A built-in horizon tilt indicator keeps your shots perfectly leveled, rewarding you with bonus score points for an exact `< 1.5°` tilt.

### 💯 Live Scoring Engine
Every frame computes a smoothed, jumping-free score (0–100) based on tilt, subject positioning, and active rules, visualized through a sleek, animated side-meter widget.

---

## 🛠️ Technology Stack

| Architecture Layer | Technology Used |
| :--- | :--- |
| **Framework** | Flutter 3.22+ / Dart 3.4+ |
| **State Management** | Riverpod 2.x (`AsyncNotifier` & `StateNotifier`) |
| **Camera Feed** | `camera` package (`startImageStream` for analysis) |
| **Machine Learning** | `google_mlkit_face_detection`, `google_mlkit_image_labeling` |
| **Device Sensors** | `sensors_plus` (gravity & accelerometer) |
| **Graphics / Rendering** | Flutter `CustomPainter` (allocation-free, 60fps safe) |
| **Animations & UI** | `flutter_animate`, `HapticFeedback` |

---

## 🎨 UI & Design Aesthetics

FrameIQ embraces a premium dark-mode aesthetic, utilizing a rich "deep space" surface (`#0A0A0F`) accented by vibrant Lime-Yellow (`#E8FF47`) and Sky Blue (`#47C8FF`) indicators. 

**Key UX Highlights:**
- **Pill-shaped Coaching Cards**: Elegant, auto-fading glassmorphic panels for warnings and tips.
- **Zero Distractions**: Overlays intelligently fade out to 40% when you compose perfectly, and disappear completely when the device is still.
- **Haptic Confirmations**: Deep tactile feedback when taking shots or hitting perfect framing.

---

## ⚙️ Prerequisites & Setup

### Requirements
- Flutter SDK `^3.22.0`
- A physical Android (API 26+) or iOS (14+) device. *(ML Kit and Camera Streams run poorly on emulators).*

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/frameiq.git
   cd frameiq
   ```

2. **Fetch Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the Application:**
   ```bash
   flutter run --release
   ```
   *(Running in release or profile mode is highly recommended to experience smooth 60fps rendering of the composition painters).*

### Platform Permissions
FrameIQ handles permissions automatically on launch, but ensure your app manifests are configured:
- **Android**: `CAMERA`, `WAKE_LOCK`, `INTERNET`, `READ/WRITE_EXTERNAL_STORAGE`
- **iOS**: Needs `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` in `Info.plist`.

---

## 🗺️ Project Structure Overview

```text
lib/
├── main.dart               # App entry and device orientation locks
├── core/                   # Theme tokens, app colors, and global constants
├── features/
│   ├── camera/             # The heart of the app
│   │   ├── domain/         # Enums (SceneModes) & Models (FrameAnalysis)
│   │   ├── data/           # ML Kit Services (SceneDetector, FaceCoach)
│   │   └── presentation/   # Camera UI, CustomPainters, and Riverpod Controllers
│   ├── coaching/           # Engine that assembles ML + Sensor data into UI states
│   └── settings/           # User preferences and shot history
└── shared/                 # Utilities and extensions
```

---

## 🚀 Roadmap (Phase 2)
We are actively building out advanced functionality:
- [ ] **Gallery Review**: View saved photos layered with the composition guides used to take them.
- [ ] **Learn Mode**: Tap any suggestion pill for a full-screen diagram and photography lesson.
- [ ] **OpenRouter AI Gen Tip**: Offload snapshot thumbnails to an LLM (Gemini Flash) for deep contextual advice.
- [ ] **Pro Overlays**: Introduce Phi Grids and the Rule of Odds.

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
