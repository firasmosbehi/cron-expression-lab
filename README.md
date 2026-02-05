# Cron Expression Generator & Tester

Mobile-first Flutter app that lets you pick a schedule (“Every Monday at 5 PM”), generates the cron string, and verifies what it actually does with upcoming run times.

## Features
- Visual schedule builder: every minute/hour/day/week/month, plus custom entry.
- Cron verifier: parses any cron string and shows the next occurrences in local time and UTC.
- Quick presets for common recipes.
- Optional “Pro” affordances (demo): saved recipes, dark mode toggle, no ads placeholder.
- Works offline for generation/verification (pure Dart cron parser).

## Screens
- Hero header with quick badges.
- Builder card (segmented frequency selector, sliders/time pickers, day chips).
- Manual verifier card with presets.
- Results card with human-readable meaning + upcoming runs.
- Saved recipes card (locked until Pro).

## Tech
- Flutter (Material 3)
- Packages: `cron_expression_parser`, `google_fonts`, `intl`

## Run
```bash
flutter pub get
flutter run   # iOS and Android
```

## Test
```bash
flutter test
```

## Release builds
- Android AAB: `./scripts/build_android_release.sh` (uses `build/app/outputs/bundle/release/app.aab`)
- iOS archive (no codesign): `./scripts/build_ios_release.sh` then open Xcode Organizer to sign/upload.

## CI
GitHub Actions (`.github/workflows/ci.yml`) runs tests, builds a Play App Bundle, and builds iOS (no codesign) on every push/PR.

## Store prep (quick)
- Privacy policy: `store/privacy-policy.md`
- Google Play checklist: `store/metadata/play-listing.md`
- App Store checklist: `store/metadata/app-store-listing.md`
- Screenshot ideas: `store/metadata/screenshots-checklist.md`

## Monetization (concept)
- Free tier: ads placeholder.
- Pro (one-time $1.99): saved recipes, dark mode toggle, ad removal.

## Before publishing
- Update unique IDs: `applicationId` (Android) and bundle ID (iOS) to your domain.
- Provide real app icon and store graphics.
- Wire up billing if you plan to sell “Pro” as an IAP; declare ads/analytics if added.
