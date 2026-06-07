<div align="center">
  <h1>📸 FrameIQ</h1>
  <p><strong>Your AI-Powered Real-Time Photography Coach</strong></p>

  [![Flutter Version](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter)](https://flutter.dev/)
  [![Dart Version](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart)](https://dart.dev/)
  [![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
  [![State Management](https://img.shields.io/badge/Riverpod-2.x-1099f7)](https://riverpod.dev/)

  <p>
    An intelligent mobile camera app that acts as your personal photography mentor. FrameIQ detects scenes, analyzes subjects, and overlays dynamic composition guides at 60fps—so you can capture the perfect shot every time without any best shot missing.
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
- **Selfie Posture**: Background-aware ghost outline for optimal selfie positioning.

### 🧠 Real-Time AI Scene & Subject Detection
Powered by Google ML Kit, running efficiently in the background without dropping frames:
- **Scene Classification**: Automatically identifies 10+ scene types and adapts the composition overlay to match.
- **Face Coach Service**: Detects facial framing, analyzing roll/yaw angles and distance to provide instant warnings (e.g., *"Tilt head left to level up"* or *"Too close—back up"*).
- **Selfie Posture Guide**: Analyzes background scene to recommend optimal selfie positioning (environmental, symmetry, casual, dynamic).

### ⚖️ Gyroscopic Horizon Coach
Utilizes the device's accelerometer to compute the gravity vector. A built-in horizon tilt indicator keeps your shots perfectly leveled, rewarding you with bonus score points for an exact `< 1.5°` tilt.

### 💯 Live Scoring Engine
Every frame computes a smoothed, jumping-free score (0–100) based on tilt, subject positioning, and active rules, visualized through a sleek, animated side-meter widget.

### 📸 Smart Image Saving
- Captures high-resolution images using the camera's native resolution
- Automatically saves to device gallery using `image_gallery_saver`
- Quick shutter flash effect (80ms) for natural camera feel
- Haptic feedback on capture for tactile confirmation

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
| **Image Saving** | `image_gallery_saver` (device gallery integration) |
| **Permissions** | `permission_handler` (runtime permission handling) |
| **Wake Lock** | `wakelock_plus` (keep screen on during camera use) |
| **HTTP Client** | `dio` (for OpenRouter AI integration) |
| **Storage** | `shared_preferences`, `path_provider` |
| **Utilities** | `vibration`, `gap`, `lottie`, `flutter_dotenv`, `uuid` |

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
├── main.dart                          # App entry, camera initialization, orientation locks
├── app.dart                           # Root widget with theme and permission gate
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants (thresholds, intervals, API config)
│   │   └── app_colors.dart            # Color palette (deep space theme, accent colors)
│   ├── theme/
│   │   └── app_theme.dart             # Material theme configuration
│   └── widgets/                       # Shared widgets
├── features/
│   ├── camera/
│   │   ├── domain/
│   │   │   ├── enums/
│   │   │   │   ├── scene_mode.dart            # 10 scene modes (portrait, selfie, landscape, etc.)
│   │   │   │   └── composition_type.dart      # 9 composition types with ML keywords
│   │   │   └── models/
│   │   │       ├── frame_analysis.dart        # Complete analysis result model
│   │   │       ├── coaching_suggestion.dart   # Suggestion pills (warn/info/good)
│   │   │       └── selfie_posture_guide.dart  # Background-aware selfie positioning
│   │   ├── data/
│   │   │   └── services/
│   │   │       ├── scene_detector_service.dart      # ML Kit image labeling for scene detection
│   │   │       └── face_coach_service.dart          # ML Kit face detection with coaching
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── camera_screen.dart             # Main camera UI with overlays
│   │       │   ├── camera_controller_provider.dart # Riverpod camera controller
│   │       │   └── permission_gate.dart          # Runtime permission handling
│   │       ├── widgets/
│   │       │   ├── shutter_button.dart            # Capture button with flip
│   │       │   ├── mode_selector.dart             # Scene mode selector
│   │       │   ├── hud_bar.dart                   # Top bar with scene info
│   │       │   ├── score_meter.dart               # Live composition score display
│   │       │   └── suggestion_strip.dart           # Coaching suggestions carousel
│   │       └── painters/
│   │           └── composition_painter.dart        # CustomPaint for all composition overlays
│   └── coaching/
│       └── engine/
│           └── coaching_engine.dart               # Assembles ML + sensor data into analysis
└── shared/
    └── utils/
        └── camera_input_image.dart                # CameraImage to InputImage conversion
```

---

## 🎯 Scene Modes

FrameIQ automatically detects and adapts to 10 different scene types:

| Scene Mode | Emoji | Best Composition | ML Keywords |
| :--- | :--- | :--- | :--- |
| **Portrait** | 🤳 | Rule of Thirds | face, person, human, portrait, selfie, smile |
| **Selfie** | 🤳 | Selfie Posture | face, person, human, portrait, selfie, smile |
| **Landscape** | 🌄 | Rule of Thirds | sky, mountain, ocean, nature, horizon, cloud, field, sunset, sunrise |
| **Food** | 🍽 | Center Frame | food, meal, dish, drink, cuisine, snack, fruit, vegetable |
| **Architecture** | 🏛 | Symmetry | building, architecture, structure, facade, interior, window, door |
| **Macro** | 🔬 | Golden Spiral | flower, insect, texture, plant, leaf, detail |
| **Action** | ⚡ | Diagonal | sport, athlete, motion, vehicle, race, game |
| **Night** | 🌙 | Rule of Thirds | night, dark, light, neon, city night, star |
| **Street** | 🚶 | Leading Lines | street, road, city, urban, pedestrian, sidewalk |
| **Auto** | ✨ | Rule of Thirds | (automatic detection) |

---

## 📐 Composition Types

FrameIQ offers 9 different composition guides:

| Composition Type | Best For Scenes | Short Tip |
| :--- | :--- | :--- |
| **Rule of Thirds** | portrait, landscape, street, action | Place subject on power points |
| **Golden Spiral** | portrait, landscape, macro | Curl focal point to spiral center |
| **Golden Triangle** | portrait, landscape | Elements align to triangle edges |
| **Symmetry** | architecture, food, street | Keep center axis aligned |
| **Leading Lines** | landscape, architecture, street | Lines guide to your subject |
| **Diagonal** | action, street, architecture | Tilt for energy and movement |
| **Center Frame** | portrait, selfie, food, architecture | Subject centered for impact |
| **Selfie Posture** | selfie | Match pose to the scene behind you |

---

## ⚙️ Configuration & Constants

Key app constants defined in `lib/core/constants/app_constants.dart`:

- **Score Thresholds**: Good (80+), OK (60+)
- **Overlay Opacity**: Active (55%), Fade (0%), Duration (600ms)
- **Auto-hide Overlay**: After 4 seconds of no movement
- **Scene Detection Interval**: 1200ms
- **Pose Detection Interval**: 400ms
- **Score Smoothing**: 0.25 (0–1, higher = snappier)
- **Horizon Tilt Threshold**: 2.5° before warning
- **OpenRouter API**: Base URL and model configuration for AI tips

---

## 🏃‍♂️ Build & Run Instructions

### Development Mode
```bash
flutter run
```

### Profile Mode (Recommended for Testing)
```bash
flutter run --profile
```

### Release Mode (Production Build)
```bash
flutter run --release
```

### Build APK
```bash
flutter build apk --release
```

### Build App Bundle (Play Store)
```bash
flutter build appbundle --release
```

**Note**: Running in release or profile mode is highly recommended to experience smooth 60fps rendering of the composition painters.

---

## 🔧 Android Configuration

### Minimum SDK
- **minSdkVersion**: 26 (Android 8.0)
- **targetSdkVersion**: 34 (Android 14)

### Required Permissions
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.BODY_SENSORS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.INTERNET" />
```

### ML Kit Configuration
The app uses bundled ML Kit models with auto-download disabled for faster startup:
```xml
<meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="ica,object_detection,image_label" />
```

---

## 🐛 Troubleshooting

### Camera not initializing
- Ensure camera permissions are granted
- Check if another app is using the camera
- Try restarting the device
- Verify camera hardware is working

### ML Kit not detecting scenes/faces
- Ensure good lighting conditions
- Check if device meets minimum requirements
- ML Kit may perform poorly on emulators - use a physical device

### Low frame rate or laggy overlays
- Run in profile or release mode (debug mode has overhead)
- Close other apps to free up resources
- Check device performance capabilities

### Images not saving to gallery
- Verify storage permissions are granted
- Check Android 11+ scoped storage compatibility
- Ensure sufficient storage space on device

### Overlays not appearing
- Check if overlay opacity is set to 0 (device still detection)
- Verify composition type is not set to "none"
- Ensure camera preview is properly initialized

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
