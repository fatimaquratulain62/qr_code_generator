# QR Code Generator

A production-ready Flutter app for generating, saving, sharing, and managing
QR codes — built with Material Design 3, Provider, and clean architecture.

## Features

- Generate QR codes from **Text, URL, Email, Phone, SMS, WiFi, Contact
  (MECARD), and Location** — with live preview as you type
- **Save** high-resolution PNGs to the gallery (Standard / HD / Ultra HD)
- **Share** QR images via the native share sheet (WhatsApp, Gmail, Bluetooth, etc.)
- **Copy** the original content to the clipboard
- **History** with search, favorite, delete, and clear-all
- Dedicated **Favorites** screen
- **Light / Dark / System** theme, persisted locally
- Accessible: semantic labels, ≥48dp touch targets, scalable text
- No deprecated APIs, `const` constructors throughout, clean folder structure

## Project structure

```
lib/
  core/
    constants/     # App-wide constants, enums
    theme/          # Material 3 light/dark ThemeData
    utils/          # Validators
  models/           # QrType, QrHistoryItem, payload builders
  providers/        # ThemeProvider, HistoryProvider, QrProvider (Provider/ChangeNotifier)
  services/         # StorageService (SharedPreferences), QrService (capture/save/share)
  screens/          # Splash, Home (shell), History, Favorites, Settings, QR detail sheet
  widgets/          # Reusable UI: type selector, input form, preview card, list item, button
  main.dart
```

## Getting started

This deliverable contains the complete Dart/Flutter **source code**
(`lib/`, `pubspec.yaml`, assets). Native platform folders (`android/`,
`ios/`) are generated locally with the Flutter CLI, since they contain
machine-specific, regenerable boilerplate that shouldn't be hand-authored.

1. **Create the project shell and copy in the source:**
   ```bash
   flutter create --org com.yourcompany --project-name qr_code_generator qr_code_generator_app
   cd qr_code_generator_app
   # Copy this repo's lib/, pubspec.yaml, analysis_options.yaml, assets/ over the generated ones
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Add Android permissions.** Merge the contents of
   `android_manifest_snippet.xml` (included in this deliverable) into
   `android/app/src/main/AndroidManifest.xml`, and set
   `minSdk = 24` in `android/app/build.gradle`.

4. **Run:**
   ```bash
   flutter run
   ```

5. **Analyze / test:**
   ```bash
   flutter analyze
   flutter test
   ```

## Building for the Play Store

```bash
flutter build appbundle --release
```

Before publishing:
- Set a unique `applicationId` in `android/app/build.gradle`
- Add your own app icon to `assets/icons/` and configure it via
  [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) (optional)
- Sign the release build with your own keystore
- Update `AppConstants.privacyPolicyUrl` and the "Rate App" store link in
  `lib/screens/settings_screen.dart` with your real listing URLs
- Bump `version` in `pubspec.yaml` for each release

## Notes on packages

- **`gal`** is used instead of the unmaintained `image_gallery_saver` for
  saving images to the gallery (Android 13+ / iOS friendly).
- **`qr_flutter`** renders the QR code; PNG export is done by wrapping the
  preview in a `RepaintBoundary` and rasterizing it at the user's chosen
  resolution (Standard / HD / Ultra HD).
- **`permission_handler`** requests photo/storage permission only when
  needed, and only where the platform requires it.

## License

Provided as a starting point for your own app; replace placeholder text,
URLs, and branding before publishing.
