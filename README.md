# Morse Code Learning

A Flutter app to help users learn and practice International Morse Code through interactive lessons, flashcards, audio playback, and quizzes.

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
Add screenshots to `assets/images/` and reference them here.

## Roadmap
- **Practice modes**: word-level, prosigns, and Q-codes
- **Spaced repetition**: smarter scheduling for reviews
- **Offline mode**: pre-generated practice sets

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
Add a license of your choice (e.g., MIT) to `LICENSE`.
