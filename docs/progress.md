# Progress

Status verified against the filesystem and source files in the current working tree on 2026-04-24.

## Implemented

- Expo app scaffold exists with runnable scripts in `package.json` for `start`, `ios`, `android`, and `web`.
- Expo configuration exists in `app.json` with portrait orientation, light UI, iOS tablet support, and Android edge-to-edge enabled.
- A root app shell exists in `App.js`.
- Shared color tokens exist in `src/theme.js`.
- All five feature module files exist and are wired into `App.js`:
  - `src/features/whipping-boy/index.js`
  - `src/features/royal-taster/index.js`
  - `src/features/sin-eater/index.js`
  - `src/features/nomenclator/index.js`
  - `src/features/moirologist/index.js`
- Each feature exports the shared metadata contract plus a concrete React Native `Component`, so the tab rail can switch across five working in-app demos.
- A separate Flutter client now exists in `flutter_app/` with native `ios/` and `android/` project directories.
- The Flutter shell in `flutter_app/lib/main.dart` also exposes all five concept demos through a single in-app selector.
- The Flutter client now has:
  - branded app identity for `專業朋友殺手`
  - Android application id `dev.friendshipkiller`
  - iOS bundle id `dev.friendshipkiller`
  - release-oriented bundle ids and versioning
  - generated launcher icons and splash screens
  - Android signing placeholders and iOS signing templates
  - GitHub Actions workflows for CI and release validation
  - store-listing draft copy, privacy manifest, and tester feedback template
  - a release configuration script at `flutter_app/scripts/configure_release.sh`
- Flutter verification passed:
  - `flutter analyze`
  - `flutter test`

## Implemented Feature Demos

- `Whipping Boy`: interactive accountability pact demo with goal, partner, and consequence selection plus consent and pressure feedback.
- `Royal Food Taster`: message triage demo with phrase detection, toxicity scoring, deadline extraction, and a filtered safe brief.
- `Sin Eater`: staged confession ritual demo with sealing, consumption, purge, and purification states.
- `Nomenclator`: live recall demo with person switching, situational contexts, and companion prompt feeds.
- `Moirologist`: affirmation squad demo with selectable setbacks, urgency modes, and animated supporter bursts.

## Missing Or Incomplete

- There is no navigation system beyond the single-screen shell in `App.js`.
- There is no backend integration, persistence layer, authentication flow, or networked multi-user state.
- There is no notification integration or platform-specific mobile surface such as widgets, wearable delivery, or health integrations.
- The Expo client still has no automated tests in the current repo snapshot.
- Feature implementations are still prototype-style: sample data, local state, and in-file styles rather than production data models or shared UI primitives.
- The Flutter client is ready for local builds, but actual TestFlight / Play Console distribution still requires:
  - your real Apple team id in `flutter_app/release.env` and `ios/Flutter/Release-Secrets.xcconfig`
  - an Android upload keystore and `flutter_app/android/key.properties`
  - actual App Store Connect and Google Play Console upload steps
- Local release-build verification was partially blocked by this machine's environment:
  - Android SDK is not configured here
  - iOS device/archive output is not fully configured here

## Suggested Resume Point

When work resumes, the shortest path to external testing is:

1. Copy `flutter_app/release.env.example` to `flutter_app/release.env` and set `IOS_TEAM_ID`.
2. Copy `flutter_app/ios/Flutter/Release-Secrets.xcconfig.example` to `flutter_app/ios/Flutter/Release-Secrets.xcconfig`.
3. Copy `flutter_app/android/key.properties.example` to `flutter_app/android/key.properties` and add the keystore file.
4. Run `bash flutter_app/scripts/configure_release.sh flutter_app/release.env`.
5. Build and upload:
   - `flutter build ipa --release`
   - `flutter build appbundle --release`

## Current Risk

The repo is now internally consistent at the module level, but the current implementations are prototype demos rather than production-ready mobile features. The main risk is architectural, not missing files: all behavior is local-only and reload-resets state.

## Git State

The working tree currently contains local modifications and new release-support files. This documentation describes the current filesystem contents, not a committed release milestone.
