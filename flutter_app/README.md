# Ancient Occupation Lab Flutter App

Flutter client for the same five concepts already prototyped in the Expo app, but with real native iOS and Android project targets so you can install builds on phones and ship alpha or beta tests.

## Included Demos

- `Whipping Boy`: consensual accountability pact with partner consequence simulation
- `Royal Food Taster`: message interception, pressure scoring, and safe brief delivery
- `Sin Eater`: staged confession, consume-once flow, and purge ritual
- `Nomenclator`: social memory prompts with backstage companion cues
- `Moirologist`: one-tap validation squad with exaggerated support bursts

## Local Run

```bash
cd flutter_app
flutter pub get
flutter run
```

## Configure Real Release Identity

```bash
cd flutter_app
cp release.env.example release.env
$EDITOR release.env
bash scripts/configure_release.sh
```

That script updates:

- app name
- Android `applicationId` and Kotlin package path
- iOS bundle id
- Apple team placeholder templates
- Flutter version string

Useful targets:

```bash
flutter run -d ios
flutter run -d android
```

## Verification

```bash
flutter analyze
flutter test
```

## Beta Distribution

### iPhone via TestFlight

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Set your Apple team and replace the default bundle identifier with your own.
3. Update signing for the `Runner` target.
4. Archive the app in Xcode and upload it to App Store Connect.
5. Add friends as internal or external testers in TestFlight.

CLI build option:

```bash
flutter build ipa --release
```

### Android via Play Internal Testing

1. Set your final `applicationId` and signing config.
2. Build an Android App Bundle.
3. Upload it to Google Play Console under Internal testing.
4. Add the tester email list and share the opt-in link.

CLI build option:

```bash
flutter build appbundle --release
```

## Before Publishing

- Replace default bundle IDs and package names with your own.
- Add proper app icons and splash assets.
- Configure release signing for both platforms.
- Decide whether TestFlight / Play Internal Testing or Firebase App Distribution is your first tester channel.
- Add real backend, auth, and notifications if you want these demos to become multi-user test builds instead of local-only prototypes.

## Repo Helpers

- [android/key.properties.example](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app/android/key.properties.example): Android signing template
- [ios/Flutter/Release-Secrets.xcconfig.example](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app/ios/Flutter/Release-Secrets.xcconfig.example): iOS signing template
- [../docs/flutter-release-checklist.md](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/docs/flutter-release-checklist.md): release and tester checklist
- [release.env.example](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app/release.env.example): one-file release identity template
- [scripts/configure_release.sh](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app/scripts/configure_release.sh): apply app name, ids, team id, and version across the project
