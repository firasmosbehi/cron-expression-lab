#!/usr/bin/env bash
# Build a Play-ready Android App Bundle (AAB).
# - Expects a keystore + android/key.properties for real signing; otherwise uses debug key.
# - Honors version/build from pubspec.yaml unless overridden via env:
#   BUILD_NAME=1.0.1 BUILD_NUMBER=2 ./scripts/build_android_release.sh

set -euo pipefail

APP_VERSION="$(grep '^version:' pubspec.yaml | awk '{print $2}')"
DEFAULT_BUILD_NAME="${APP_VERSION%%+*}"
DEFAULT_BUILD_NUMBER="${APP_VERSION##*+}"

BUILD_NAME="${BUILD_NAME:-$DEFAULT_BUILD_NAME}"
BUILD_NUMBER="${BUILD_NUMBER:-$DEFAULT_BUILD_NUMBER}"

echo "Using build-name=$BUILD_NAME build-number=$BUILD_NUMBER"

if [[ -f "android/key.properties" ]]; then
  echo "Using android/key.properties for signing."
else
  echo "⚠️  No key.properties found; Flutter will use the debug signing config."
fi

flutter clean
flutter pub get
flutter build appbundle \
  --release \
  --build-name "$BUILD_NAME" \
  --build-number "$BUILD_NUMBER"

echo "AAB ready at build/app/outputs/bundle/release/app.aab"
