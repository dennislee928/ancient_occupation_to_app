# GitHub Actions Secrets Setup

This repo already includes:

- [flutter-ci.yml](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/.github/workflows/flutter-ci.yml)
- [flutter-release.yml](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/.github/workflows/flutter-release.yml)

## Release Workflow Outputs

`Flutter Release Validation` now uploads:

- `android-apk`: direct-install Android artifact
- `android-appbundle`: Play Console artifact
- `ios-ipa`: signed iPhone artifact when Apple signing secrets are configured
- `ios-runner-app`: unsigned fallback artifact when Apple signing secrets are missing

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

## iOS Secrets

Required if you want GitHub Actions to build a signed `.ipa`:

- `APPLE_TEAM_ID`
- `APPLE_CERTIFICATE_P12_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_PROVISIONING_PROFILE_BASE64`

Optional:

- `APPLE_KEYCHAIN_PASSWORD`

### Create `APPLE_CERTIFICATE_P12_BASE64`

Export your Apple Distribution certificate as a `.p12`, then run:

```bash
base64 -i path/to/certificate.p12 | pbcopy
```

### Create `APPLE_PROVISIONING_PROFILE_BASE64`

Download the provisioning profile you want CI to use, then run:

```bash
base64 -i path/to/profile.mobileprovision | pbcopy
```

Paste each copied value into the matching GitHub secret.

If the iOS secrets are missing, the workflow still performs an unsigned iOS release build and uploads `ios-runner-app`, but it will not produce an installable `.ipa`.

## Recommended Repository Variables

Use GitHub repository variables for non-secret release defaults:

- `FLUTTER_BUILD_NAME`
- `FLUTTER_BUILD_NUMBER`
- `IOS_BUNDLE_ID`
- `ANDROID_APPLICATION_ID`

## Suggested Setup Order

1. Add Android signing secrets first.
2. Add `IOS_BUNDLE_ID` as a repository variable.
3. Add the Apple signing secrets if you want CI to output `ios-ipa`.
4. Run `Flutter Release Validation` manually from GitHub Actions.
5. Confirm the `android-apk`, `android-appbundle`, and optionally `ios-ipa` artifacts download correctly.
