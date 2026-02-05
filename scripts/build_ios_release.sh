#!/usr/bin/env bash
# Build an iOS release archive without code signing (for CI/TestFlight upload via Xcode later).
# For real distribution, archive in Xcode with your team signing or use flutter build ipa with export options.

set -euo pipefail

flutter clean
flutter pub get

# --no-codesign keeps CI simple; you'll sign in Xcode Organizer/Transporter for App Store submission.
flutter build ios --release --no-codesign

echo "iOS archive built at build/ios/iphoneos/Runner.app (or via Xcode archive in build/ios/archive)"
