# Flutter Release Checklist

## App Identity

- Copy [flutter_app/release.env.example](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app/release.env.example) to `flutter_app/release.env`.
- Fill in your real app name, bundle ids, Apple team id, and version values.
- Run [flutter_app/scripts/configure_release.sh](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app/scripts/configure_release.sh).
- Confirm the Flutter client version in [flutter_app/pubspec.yaml](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app/pubspec.yaml).
- Current default repo identity:
  - app name: `專業朋友殺手`
  - iOS: `dev.friendshipkiller`
  - Android: `dev.friendshipkiller`
- Decide whether to keep or change those values before submission.
- Increment `version:` for every tester build you distribute.

## Android Signing

- Copy [flutter_app/android/key.properties.example](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app/android/key.properties.example) to `flutter_app/android/key.properties`.
- Generate or import an upload keystore.
- Place the keystore at `flutter_app/android/app/upload-keystore.jks` or change `storeFile`.
- Build a signed bundle:

```bash
cd flutter_app
flutter build appbundle --release
```

## iOS Signing

- Copy [flutter_app/ios/Flutter/Release-Secrets.xcconfig.example](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app/ios/Flutter/Release-Secrets.xcconfig.example) to `flutter_app/ios/Flutter/Release-Secrets.xcconfig`.
- Fill in `DEVELOPMENT_TEAM`.
- Open `flutter_app/ios/Runner.xcworkspace` in Xcode.
- Verify signing, capabilities, and provisioning for the `Runner` target.
- If you want CLI export options, copy [flutter_app/ios/ExportOptions.testflight.plist.example](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app/ios/ExportOptions.testflight.plist.example) to `flutter_app/ios/Runner/ExportOptions.plist` and set the team id.

## Tester Distribution

### TestFlight

1. Archive in Xcode or run:

```bash
cd flutter_app
flutter build ipa --release
```

2. Upload to App Store Connect.
3. Add internal or external testers in TestFlight.

### Google Play Internal Testing

1. Build:

```bash
cd flutter_app
flutter build appbundle --release
```

2. Upload the `.aab` to Play Console.
3. Create or update an Internal testing track.
4. Add tester emails and share the opt-in URL.

## GitHub Actions Secrets

The release workflow expects these secrets for signed Android builds:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_STORE_PASSWORD`

Optional iOS/App Store Connect secrets can be added later if you want to automate signed uploads rather than only build validation.
