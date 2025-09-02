# Morse Code Learning

A Flutter app to help users learn and practice International Morse Code through interactive lessons, flashcards, audio playback, and quizzes.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://docs.flutter.dev) [![Dart](https://img.shields.io/badge/Dart-3.x-blue)](https://dart.dev) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features
- **Interactive lessons**: Learn dots and dashes with a progressive curriculum
- **Flashcards**: Practice letter-to-code and code-to-letter recognition
- **Audio playback**: Hear dot/dash tones and full-character playback
- **Quizzes**: Timed challenges with detailed results
- **Progress tracking**: Track accuracy and streaks over time
- **Customizable settings**: Control WPM, tone, and difficulty
- **Cross‑platform**: Android, iOS, Web, Windows, macOS, Linux

## Tech Stack
- **Framework**: Flutter (Dart)
- **UI**: Material + custom themes
- **Audio**: Local tone assets in `assets/audio/`

## Getting Started
### Prerequisites
- Flutter SDK installed — see the official docs: https://docs.flutter.dev/get-started/install
- A device/emulator/simulator for your platform

### Setup
```
flutter --version
flutter pub get
```

### Run
```
# Choose one of the following based on your target
flutter run                      # auto-detects a device
flutter run -d chrome            # Web
flutter run -d android           # Android
flutter run -d ios               # iOS (on macOS)
flutter run -d windows           # Windows
flutter run -d macos             # macOS
flutter run -d linux             # Linux
```

## Project Structure (excerpt)
```
lib/
  main.dart
  screens/
  helper/
  services/
  theme/
assets/
  audio/
  images/
```

## Screenshots
Place screenshots in `assets/images/` and reference them here.

Example:

![Welcome Screen](assets/images/welcome.png)
![Tree Screen](assets/images/tree.png)

## Roadmap
- **Practice modes**: word-level, prosigns, and Q-codes
- **Spaced repetition**: smarter scheduling for reviews
- **Offline mode**: pre-generated practice sets

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License — see [`LICENSE`](LICENSE).
