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

## Clone And Run

Clone the repository:

```bash
git clone https://github.com/asmasaeed18as/quizlet-flutter-project.git
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


## Default Entry Point

The app starts from:

- `lib/main.dart`

Current initial screen:

- `SplashScreen`

## Author

Mobile App Development project repository.
