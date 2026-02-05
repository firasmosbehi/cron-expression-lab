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

## Monetization (concept)
- Free tier: ads placeholder.
- Pro (one-time $1.99): saved recipes, dark mode toggle, ad removal.
