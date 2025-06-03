# Finger Chooser Dare App

## 👆🎉 Description

Finger Chooser Dare App is a fun mobile application built with Flutter that allows a group of users to randomly select one person using their fingers on the screen. The selected person might then be presented with a dare. The app supports different game modes, custom dare lists, and multiple languages.

## ✨ Features

*   **Party Play:** Randomly selects one finger from multiple fingers placed on the screen and assigns a dare to the chosen person.
*   **Quick Pick:** A simple finger chooser mode without any dares involved.
*   **Custom Play (Wizard):**
    *   Create, save, and manage multiple custom lists of dares.
    *   Add, edit, and delete dares within these custom lists.
    *   Start a game using a selected custom dare list.
*   **Dare System:**
    *   Dares are loaded from a configurable source (Firebase Remote Config with local JSON fallback).
    *   (Future work: Dare packs, filtering based on criteria like group type, intensity).
*   **Localization:** Supports English and Arabic languages throughout the app.
*   **Settings:** Allows users to switch the app language.
*   **Store (UI Placeholder):** A screen displaying placeholder dare packs for future expansion.
*   **Sound & Haptic Feedback:** Enhances user experience with auditory and tactile feedback for key interactions.
*   **Firebase Integration:**
    *   **Analytics:** Logs basic events like starting different game modes.
    *   **Remote Config:** Dares (specifically `core_dares.json`) can be updated remotely.

## 🚀 Getting Started

### Prerequisites

*   Flutter SDK: Make sure you have Flutter installed. See [Flutter installation guide](https://flutter.dev/docs/get-started/install).
*   An editor like VS Code or Android Studio.
*   A device or emulator to run the app.

### Setup

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd finger_chooser_app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup (Crucial for full functionality):**
    *   Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/).
    *   Register your Flutter app (iOS and/or Android) with this project.
    *   **Android:** Download the `google-services.json` file from your Firebase project settings and place it in the `android/app/` directory.
    *   **iOS:** Download the `GoogleService-Info.plist` file from your Firebase project settings and place it in the `ios/Runner/` directory (usually done by opening the iOS module in Xcode and adding the file).
    *   **Remote Config:** In the Firebase console, navigate to "Remote Config".
        *   Add a parameter with the key `core_dares_json`.
        *   Set its value to be the JSON content you want to serve (e.g., copy the content from `assets/dares/core_dares.json` or provide your updated JSON).
        *   Publish the Remote Config changes.
        *   If you don't set this up, the app will fall back to using the local `assets/dares/core_dares.json`.

4.  **Run the app:**
    ```bash
    flutter run
    ```

## 🛠️ State Management

This project uses [Riverpod](https://riverpod.dev/) for state management, providing a robust and scalable way to manage application state.

## 📁 Directory Structure (Feature-First)

The project follows a feature-first directory structure to organize code by features, making it easier to navigate and manage:

```
lib/
├── app.dart                # Main application widget (MaterialApp setup)
├── main.dart               # Main entry point of the application
│
├── features/               # Contains all application features
│   ├── home/               # Home screen (mode selection)
│   │   └── presentation/
│   │       └── screens/
│   │           └── home_screen.dart
│   ├── finger_chooser/     # Core finger choosing logic and UI
│   │   ├── presentation/
│   │   │   ├── provider/   # Riverpod providers for chooser state
│   │   │   ├── screens/    # Chooser screen UI
│   │   │   └── widgets/    # Specific widgets for chooser
│   ├── dare_display/       # Screen for displaying dares
│   ├── custom_play/        # Custom dare list creation wizard
│   ├── settings/           # Settings screen (language, etc.)
│   ├── store/              # Dare pack store UI
│   └── ...                 # Other features
│
├── models/                 # Data models (Dare, Finger, DarePack, etc.)
├── services/               # Services (DareService, FeedbackService, etc.)
├── providers/              # Global Riverpod providers (e.g., LocaleNotifier)
├── l10n/                   # Localization files (.arb)
├── assets/                 # Static assets (JSON dares, sounds, images)
│   ├── dares/
│   └── sounds/
│
└── ...                     # Other project files (tests, etc.)
```

##🤝 Contributing (Placeholder)

Contributions are welcome! If you'd like to contribute, please follow these steps:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature-name`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add some feature'`).
5. Push to the branch (`git push origin feature/your-feature-name`).
6. Open a Pull Request.

Please ensure your code adheres to the existing style and includes tests where appropriate.

---

This README provides a good overview for users and developers.
Remember to replace `<repository-url>` with the actual URL if you host this project.
The "Contributing" section is a standard placeholder.
```
