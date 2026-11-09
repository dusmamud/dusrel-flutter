# dusrel-flutter

DusRel Flutter monorepo — Pub Workspaces + Melos, with 4 apps sharing one
workspace. Created 2026-11-09 with Flutter 3.47.9, Dart 3.13.7, Melos 8.10.1.

## Structure

```
dusrel-flutter/
├── pubspec.yaml          # workspace root (workspace: apps/*, packages/*)
├── apps/
│   ├── notes/            # com.dusrel.app.notes
│   ├── chat/             # com.dusrel.app.chat
│   ├── calendar/         # com.dusrel.app.calendar
│   └── drive/            # com.dusrel.app.drive
└── packages/
    └── core/             # shared code, used by all 4 apps
```

Each app targets all 6 Flutter platforms: Android, iOS, Windows, macOS,
Linux, Web. Android applicationId and iOS bundle id are
`com.dusrel.app.<app>` (e.g. `com.dusrel.app.notes`).

## Commands (run from this root)

```sh
melos bootstrap            # install workspace dependencies
melos analyze              # flutter analyze in every package
melos test                 # flutter test in every package
```

Build one app, e.g. notes:

```sh
cd apps/notes
flutter build linux        # Linux desktop (verified)
flutter build apk          # Android APK — needs Android SDK licenses accepted
                           # (see note below)
flutter build web
```

## Notes

- All 4 apps are still the default Flutter counter template — real features
  (notes, chat, calendar, drive) are yet to be built.
- Android builds need `flutter doctor --android-licenses`, which cannot run
  in this sandbox yet: Java networking is blocked by the `other_tcp`
  permission (Muse Settings → Permissions → Direct network protocols →
  Deny → Ask). Linux builds work fine.
- iOS/macOS/Windows builds cannot run on this Linux machine; their platform
  folders are generated and ready for a Mac/Windows machine.
