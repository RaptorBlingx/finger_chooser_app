# 👆 Finger Chooser

> **A fun, multi-touch party game that randomly picks a finger — and assigns a dare!**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)](#getting-started)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](#license)

---

## About

**Finger Chooser** is a multiplayer mobile app where players place their fingers on the screen and the app randomly selects one — making it the perfect icebreaker, party game, or decision-maker. With two exciting play modes, a curated dare system, multi-language support, and beautiful animations, Finger Chooser turns any gathering into an unforgettable experience.

---

## ✨ Features

- 🎉 **Party Play** — Place fingers, pick a loser, reveal a dare from curated dare packs
- 👆 **Quick Pick** — Fast, no-frills random finger selection for instant decisions
- 🛠️ **Custom Play Wizard** — Personalize games with custom dares, player counts, relationships, locations, and gender settings
- 🛒 **Dare Pack Store** — Browse and unlock themed dare packs to spice up gameplay
- 🌍 **Multi-language Support** — Full English & Arabic (RTL) localization
- 🎨 **Ultra UI** — Glassmorphism, gradient backgrounds, glow effects, particle animations, and confetti celebrations
- 🔊 **Sound & Haptics** — Audio feedback and haptic responses for every interaction
- 📊 **Firebase Integration** — Analytics, Remote Config, and Crashlytics built-in
- 📱 **AdMob Ads** — Banner ads integrated gracefully

---

## 🎮 Gameplay Modes

| Mode | Description |
|------|-------------|
| 🎉 **Party Play** | All players place fingers → countdown → one finger is chosen → a dare is assigned to the loser |
| 👆 **Quick Pick** | All players place fingers → countdown → one finger is randomly highlighted as the winner |
| 🛠️ **Custom Play** | Set up a fully customized game with dares, player count, relationship type, location, and more |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | [Flutter](https://flutter.dev) |
| Language | [Dart](https://dart.dev) |
| State Management | [Riverpod](https://riverpod.dev) |
| Backend / Analytics | [Firebase](https://firebase.google.com) (Core, Analytics, Crashlytics, Remote Config) |
| Ads | [Google Mobile Ads](https://pub.dev/packages/google_mobile_ads) |
| Audio | [audioplayers](https://pub.dev/packages/audioplayers) |
| Animations | [flutter_animate](https://pub.dev/packages/flutter_animate), [lottie](https://pub.dev/packages/lottie), [confetti](https://pub.dev/packages/confetti) |
| Fonts | [Google Fonts](https://pub.dev/packages/google_fonts) |
| Localization | Flutter Gen + ARB files (EN / AR) |
| Persistence | [shared_preferences](https://pub.dev/packages/shared_preferences) |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.5.4`
- [Dart SDK](https://dart.dev/get-dart) `^3.5.4`
- [Firebase project](https://console.firebase.google.com/) configured for Android & iOS
- Android Studio / Xcode for device emulation

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/RaptorBlingx/finger_chooser_app.git
   cd finger_chooser_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (Riverpod providers & localization)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Setup

This project requires Firebase. Ensure you have:
- `google-services.json` in `android/app/`
- `GoogleService-Info.plist` in `ios/Runner/`
- `lib/firebase_options.dart` generated via the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── theme/           # App-wide theme (AppTheme)
│   └── widgets/         # Reusable UI components (GlassCard, GradientButton)
├── features/
│   ├── finger_chooser/  # Core chooser screen with multi-touch detection
│   ├── home/            # Home screen with mode selection
│   ├── dare_display/    # Dare reveal screen
│   ├── custom_play/     # Custom Play Wizard (multi-step setup)
│   └── store/           # Dare Pack store
├── models/              # Data models (Finger, Dare, DarePack, FilterCriteria)
├── providers/           # Global Riverpod providers (locale, preferences)
├── services/            # Business logic (DareService, AdMobService)
├── l10n/                # Localization files (app_en.arb, app_ar.arb)
├── app.dart             # Root MaterialApp configuration
└── main.dart            # Entry point (Firebase + AdMob init)
assets/
└── dares/               # Bundled dare content files
```

---

## 🌐 Localization

The app supports **English** and **Arabic** out of the box with full RTL layout support.

To add a new language:
1. Create `lib/l10n/app_<locale>.arb`
2. Add the locale to `supportedLocales` in `app.dart`

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<p align="center">Made with ❤️ using Flutter</p>
