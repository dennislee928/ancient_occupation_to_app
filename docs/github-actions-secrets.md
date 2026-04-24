# GitHub Actions Secrets Setup

This repo already includes:

- [flutter-ci.yml](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/.github/workflows/flutter-ci.yml)
- [flutter-release.yml](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/.github/workflows/flutter-release.yml)

## Android Secrets

Required for signed Android release artifacts:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_STORE_PASSWORD`

### Create `ANDROID_KEYSTORE_BASE64`

```bash
base64 -i flutter_app/android/app/upload-keystore.jks | pbcopy
```

Paste the copied value into the GitHub secret.

## Optional Future iOS Secrets

The current workflow only validates iOS release builds without codesigning. If you later want to automate signed uploads, add secrets for:

- App Store Connect API key id
- App Store Connect issuer id
- App Store Connect private key
- Apple team id
- match / provisioning or manual certificate material

## Recommended Repository Variables

Use GitHub repository variables for non-secret release defaults:

- `FLUTTER_BUILD_NAME`
- `FLUTTER_BUILD_NUMBER`
- `IOS_BUNDLE_ID`
- `ANDROID_APPLICATION_ID`

## Suggested Setup Order

1. Add Android signing secrets first.
2. Run `Flutter Release Validation` manually from GitHub Actions.
3. Confirm the Android `.aab` artifact downloads correctly.
4. Keep iOS as local/Xcode-driven signing until you want fully automated distribution.
