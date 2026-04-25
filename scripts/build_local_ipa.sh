#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_DIR="$ROOT_DIR/flutter_app"
RELEASE_ENV="$FLUTTER_DIR/release.env"
RELEASE_ENV_EXAMPLE="$FLUTTER_DIR/release.env.example"
CONFIGURE_RELEASE_SCRIPT="$FLUTTER_DIR/scripts/configure_release.sh"
RELEASE_SECRETS="$FLUTTER_DIR/ios/Flutter/Release-Secrets.xcconfig"
RELEASE_SECRETS_EXAMPLE="$FLUTTER_DIR/ios/Flutter/Release-Secrets.xcconfig.example"
EXPORT_OPTIONS="$FLUTTER_DIR/ios/Runner/ExportOptions.plist"
EXPORT_OPTIONS_EXAMPLE="$FLUTTER_DIR/ios/ExportOptions.testflight.plist.example"
IPA_DIR="$FLUTTER_DIR/build/ios/ipa"

usage() {
  cat <<EOF
Build a local iOS .ipa for the Flutter app.

Usage:
  bash scripts/build_local_ipa.sh
  bash scripts/build_local_ipa.sh --skip-checks

Options:
  --skip-checks   Skip flutter analyze and flutter test before building.
  -h, --help      Show this help text.
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

require_file() {
  local file_path="$1"
  local hint="$2"
  [[ -f "$file_path" ]] || die "$hint"
}

ensure_no_placeholder() {
  local file_path="$1"
  local pattern="$2"
  local hint="$3"

  if rg -q "$pattern" "$file_path"; then
    die "$hint"
  fi
}

skip_checks=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-checks)
      skip_checks=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

command -v flutter >/dev/null 2>&1 || die "Flutter is not installed or not on PATH."
command -v rg >/dev/null 2>&1 || die "ripgrep (rg) is required."

require_file "$RELEASE_ENV" "Missing $RELEASE_ENV. Copy $RELEASE_ENV_EXAMPLE to release.env and fill in your real values."
require_file "$RELEASE_SECRETS" "Missing $RELEASE_SECRETS. Copy $RELEASE_SECRETS_EXAMPLE and set DEVELOPMENT_TEAM."
require_file "$EXPORT_OPTIONS" "Missing $EXPORT_OPTIONS. Copy $EXPORT_OPTIONS_EXAMPLE and set teamID."

ensure_no_placeholder "$RELEASE_ENV" 'CHANGE_ME' "release.env still contains CHANGE_ME. Set IOS_TEAM_ID before building."
ensure_no_placeholder "$RELEASE_SECRETS" 'CHANGE_ME' "Release-Secrets.xcconfig still contains CHANGE_ME. Set DEVELOPMENT_TEAM before building."
ensure_no_placeholder "$EXPORT_OPTIONS" 'CHANGE_ME' "ExportOptions.plist still contains CHANGE_ME. Set teamID before building."

echo "Syncing release identity into Flutter platform files..."
bash "$CONFIGURE_RELEASE_SCRIPT" "$RELEASE_ENV"

if [[ -d "$FLUTTER_DIR/android/app/src/main/kotlin" ]] && find "$FLUTTER_DIR/android/app/src/main/kotlin" -type d -name '*\\*' | grep -q .; then
  die "Malformed Android Kotlin path detected under flutter_app/android/app/src/main/kotlin. Fix the org\\/ path created by the old release script before continuing."
fi

cd "$FLUTTER_DIR"

echo "Running flutter pub get..."
flutter pub get

if [[ "$skip_checks" != true ]]; then
  echo "Running flutter analyze..."
  flutter analyze

  echo "Running flutter test..."
  flutter test
fi

echo "Building .ipa..."
flutter build ipa --release --export-options-plist="$EXPORT_OPTIONS"

echo
echo "IPA build completed."
echo "Output directory: $IPA_DIR"
