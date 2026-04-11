# MAD Flutter Quiz App

This is a Flutter mobile app development project. The app starts with a splash screen and includes intro, login, registration, home, quiz list, and quiz screens.

## Project Structure

- `lib/` application source code
- `assets/` app images and other bundled assets
- `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` platform-specific project files
- `test/` widget and test files

## Prerequisites

Install these tools before running the project:

- Flutter SDK, stable channel
- Dart SDK, included with Flutter
- Android Studio or VS Code with Flutter and Dart extensions
- Android SDK for Android development
- Git

This project was created with Flutter `stable` and uses Dart SDK constraint `^3.10.7`.

## Recommended Setup

1. Install Flutter and add it to your system `PATH`.
2. Run:

```bash
flutter doctor
```

3. Install any missing Android toolchain components shown by `flutter doctor`.
4. Connect an Android phone with USB debugging enabled, or start an Android emulator from Android Studio.

## Clone And Run

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
cd mad
```

Install dependencies:

```bash
flutter pub get
```

Check available devices:

```bash
flutter devices
```

Run the app:

```bash
flutter run
```

## Dependencies

Main package dependencies from `pubspec.yaml`:

- `flutter`
- `cupertino_icons`

To reinstall all Dart and Flutter packages at any time:

```bash
flutter pub get
```

## Git-Ignored Files

Some files are intentionally not pushed to GitHub because they are generated locally or contain machine-specific paths.

Examples:

- `.dart_tool/`
- `build/`
- `.idea/`
- `*.iml`
- `flutter_*.log`
- `android/local.properties`
- `ios/Flutter/ephemeral/`
- `macos/Flutter/ephemeral/`

These files are not missing project files. They are recreated on each developer machine.

## Important Note About `android/local.properties`

`android/local.properties` is not stored in Git because it contains local SDK paths such as:

- Android SDK path
- Flutter SDK path

This file is normally generated automatically when:

- Flutter is installed correctly
- Android SDK is installed correctly
- you run `flutter pub get` or `flutter run`

If it does not generate automatically, make sure:

```bash
flutter doctor
```

shows no major Android setup issues.

## Useful Commands

Get packages:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run on a specific device:

```bash
flutter run -d <device-id>
```

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Clean generated files and rebuild:

```bash
flutter clean
flutter pub get
flutter run
```

Build APK:

```bash
flutter build apk
```

## If The Project Does Not Run

Try this order:

1. Run `flutter doctor`
2. Run `flutter clean`
3. Run `flutter pub get`
4. Make sure an emulator or phone is connected
5. Run `flutter run`

## What Should Be On GitHub

These should be committed:

- `lib/`
- `assets/`
- `test/`
- `android/`
- `ios/`
- `web/`
- `windows/`
- `linux/`
- `macos/`
- `pubspec.yaml`
- `pubspec.lock`
- `analysis_options.yaml`
- `.metadata`
- `README.md`

These should not be committed:

- `build/`
- `.dart_tool/`
- IDE-specific temporary files
- local SDK path files
- generated logs
- generated ephemeral folders

## Default Entry Point

The app starts from:

- `lib/main.dart`

Current initial screen:

- `SplashScreen`

## Author

Mobile App Development project repository.
