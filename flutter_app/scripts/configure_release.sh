#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${1:-$ROOT_DIR/release.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing env file: $ENV_FILE"
  echo "Copy $ROOT_DIR/release.env.example to $ROOT_DIR/release.env and edit it first."
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

required_vars=(
  APP_NAME
  APP_NAME_SLUG
  ANDROID_APPLICATION_ID
  IOS_BUNDLE_ID
  IOS_TEAM_ID
  BUILD_NAME
  BUILD_NUMBER
)

for name in "${required_vars[@]}"; do
  if [[ -z "${!name:-}" ]]; then
    echo "Required variable $name is missing in $ENV_FILE"
    exit 1
  fi
done

escape_replacement() {
  printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}

escape_pattern() {
  printf '%s' "$1" | sed 's/[][(){}.^$*+?|\/\\]/\\&/g'
}

PUBSPEC="$ROOT_DIR/pubspec.yaml"
GRADLE="$ROOT_DIR/android/app/build.gradle.kts"
MANIFEST="$ROOT_DIR/android/app/src/main/AndroidManifest.xml"
PLIST="$ROOT_DIR/ios/Runner/Info.plist"
PBXPROJ="$ROOT_DIR/ios/Runner.xcodeproj/project.pbxproj"
MAIN_DART="$ROOT_DIR/lib/main.dart"
IOS_RELEASE_SECRETS_EXAMPLE="$ROOT_DIR/ios/Flutter/Release-Secrets.xcconfig.example"
IOS_DEBUG_SECRETS_EXAMPLE="$ROOT_DIR/ios/Flutter/Debug-Secrets.xcconfig.example"

OLD_ANDROID_ID="$(sed -n 's/.*namespace = "\(.*\)"/\1/p' "$GRADLE" | head -n1)"
OLD_IOS_ID="$(sed -n 's/.*PRODUCT_BUNDLE_IDENTIFIER = \(.*\);/\1/p' "$PBXPROJ" | head -n1 | tr -d ' ')"
OLD_APP_NAME="$(sed -n 's/.*android:label="\([^"]*\)".*/\1/p' "$MANIFEST" | head -n1)"
OLD_APP_NAME_SLUG="$(sed -n '/<key>CFBundleName<\/key>/{n;s/.*<string>\(.*\)<\/string>.*/\1/p;}' "$PLIST" | head -n1)"
OLD_BUILD_NAME="$(sed -n 's/^version: \([^+]*\)+.*/\1/p' "$PUBSPEC" | head -n1)"
OLD_BUILD_NUMBER="$(sed -n 's/^version: [^+]*+\(.*\)$/\1/p' "$PUBSPEC" | head -n1)"

OLD_ANDROID_ID_PATTERN="$(escape_pattern "$OLD_ANDROID_ID")"
OLD_IOS_ID_PATTERN="$(escape_pattern "$OLD_IOS_ID")"
OLD_APP_NAME_PATTERN="$(escape_pattern "$OLD_APP_NAME")"
OLD_APP_NAME_SLUG_PATTERN="$(escape_pattern "$OLD_APP_NAME_SLUG")"
OLD_BUILD_NAME_PATTERN="$(escape_pattern "$OLD_BUILD_NAME")"
OLD_BUILD_NUMBER_PATTERN="$(escape_pattern "$OLD_BUILD_NUMBER")"

NEW_ANDROID_ID_REPL="$(escape_replacement "$ANDROID_APPLICATION_ID")"
NEW_IOS_ID_REPL="$(escape_replacement "$IOS_BUNDLE_ID")"
NEW_IOS_TEST_ID_REPL="$(escape_replacement "${IOS_BUNDLE_ID}.RunnerTests")"
NEW_APP_NAME_REPL="$(escape_replacement "$APP_NAME")"
NEW_APP_NAME_SLUG_REPL="$(escape_replacement "$APP_NAME_SLUG")"
NEW_BUILD_NAME_REPL="$(escape_replacement "$BUILD_NAME")"
NEW_BUILD_NUMBER_REPL="$(escape_replacement "$BUILD_NUMBER")"
NEW_TEAM_REPL="$(escape_replacement "$IOS_TEAM_ID")"

perl -0pi -e "s/$OLD_ANDROID_ID_PATTERN/$NEW_ANDROID_ID_REPL/g" "$GRADLE" "$MAIN_DART"
perl -0pi -e "s/$OLD_APP_NAME_PATTERN/$NEW_APP_NAME_REPL/g" "$MANIFEST" "$PLIST" "$MAIN_DART"
perl -0pi -e "s/$OLD_APP_NAME_SLUG_PATTERN/$NEW_APP_NAME_SLUG_REPL/g" "$PLIST"
perl -0pi -e "s/$OLD_BUILD_NAME_PATTERN\\+$OLD_BUILD_NUMBER_PATTERN/$NEW_BUILD_NAME_REPL+$NEW_BUILD_NUMBER_REPL/g" "$PUBSPEC"

perl -0pi -e "s/${OLD_IOS_ID_PATTERN}\.RunnerTests/$NEW_IOS_TEST_ID_REPL/g" "$PBXPROJ"
perl -0pi -e "s/$OLD_IOS_ID_PATTERN/$NEW_IOS_ID_REPL/g" "$PBXPROJ" "$IOS_RELEASE_SECRETS_EXAMPLE" "$IOS_DEBUG_SECRETS_EXAMPLE"
perl -0pi -e "s/DEVELOPMENT_TEAM = .*/DEVELOPMENT_TEAM = $NEW_TEAM_REPL/g" "$IOS_RELEASE_SECRETS_EXAMPLE" "$IOS_DEBUG_SECRETS_EXAMPLE"
perl -0pi -e "s/MARKETING_VERSION = [^;]+;/MARKETING_VERSION = $NEW_BUILD_NAME_REPL;/g" "$PBXPROJ"

OLD_KOTLIN_PATH="$ROOT_DIR/android/app/src/main/kotlin/${OLD_ANDROID_ID//./\/}/MainActivity.kt"
NEW_KOTLIN_PATH="$ROOT_DIR/android/app/src/main/kotlin/${ANDROID_APPLICATION_ID//./\/}/MainActivity.kt"

if [[ -f "$OLD_KOTLIN_PATH" && "$OLD_KOTLIN_PATH" != "$NEW_KOTLIN_PATH" ]]; then
  mkdir -p "$(dirname "$NEW_KOTLIN_PATH")"
  mv "$OLD_KOTLIN_PATH" "$NEW_KOTLIN_PATH"

  OLD_ROOT="$ROOT_DIR/android/app/src/main/kotlin/${OLD_ANDROID_ID%%.*}"
  if [[ -d "$OLD_ROOT" ]]; then
    find "$OLD_ROOT" -type d -empty -delete || true
  fi
fi

if [[ -f "$NEW_KOTLIN_PATH" ]]; then
  perl -0pi -e "s/$OLD_ANDROID_ID_PATTERN/$NEW_ANDROID_ID_REPL/g" "$NEW_KOTLIN_PATH"
fi

cat <<EOF
Release configuration updated.

App name: $APP_NAME
Android applicationId: $ANDROID_APPLICATION_ID
iOS bundle id: $IOS_BUNDLE_ID
Apple team id: $IOS_TEAM_ID
Version: $BUILD_NAME+$BUILD_NUMBER

Next:
  1. Copy ios/Flutter/Release-Secrets.xcconfig.example to ios/Flutter/Release-Secrets.xcconfig
  2. Copy android/key.properties.example to android/key.properties
  3. Run flutter pub get
  4. Run flutter analyze && flutter test
EOF
