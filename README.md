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
    ├── core/             # shared pure-Dart code (models, utils)
    ├── ui_kit/           # shared design system: Material 3 theme,
    │                     # tokens, buttons, search bar, avatar,
    │                     # loading/empty/error states, app shell
    └── l10n/             # shared localization (dusrel_l10n) — en_US, hi_IN
                          # ARB files in lib/l10n, generated AppLocalizations
                          # (147 keys, all translated)
```

Each app targets all 6 Flutter platforms: Android, iOS, Windows, macOS,
Linux, Web. Android applicationId and iOS bundle id are
`com.dusrel.app.<app>` (e.g. `com.dusrel.app.notes`).

## Frontend (built 2026-11-09, verified)

All 4 apps have a real frontend with mock data (no backend yet — every app
has a repository interface so the backend plugs in later without UI changes).
Shared stack: `go_router` 18.1.3, `flutter_riverpod` 3.5.0,
`material_symbols_icons` 4.2960.0, `flutter_svg`, `cached_network_image`,
`cupertino_icons` 2.0.0.

- **Notes** (9 screens): home masonry grid (hand-built — the staggered-grid
  packages are incompatible with Dart 3.13), Quill rich-text editor with
  debounced autosave, search, notebooks, labels, archive, trash, reminders,
  settings. Uses `flutter_quill` 11.6.0.
- **Chat** (10 screens): chats list, conversation (`flutter_chat_ui`
  2.12.0), new-chat picker, group/contact info, media viewer, in-chat and
  global search, settings. Updates/Communities/Calls tabs are designed
  coming-soon screens.
- **Calendar** (10 screens): month/week/day/agenda views (`table_calendar`
  3.3.0), event create/edit with recurrence (RRULE-style, display-range
  expansion), event details sheet, search, calendars manager, settings.
  Drag-to-reschedule is intentionally out of v1.
- **Drive** (14 screens): home, files, search, starred, shared, recent,
  photos, offline, trash, storage, file preview (`easy_image_viewer`),
  share sheet, upload queue (`file_picker` 13.3.2), settings.

## Commands (run from this root)

```sh
melos bootstrap            # install workspace dependencies
melos run analyze          # flutter analyze in every package
melos run test             # flutter test in every package
```

Build one app, e.g. notes:

```sh
cd apps/notes
flutter build linux        # Linux desktop (verified for all 4 apps)
flutter build apk          # Android APK — needs Android SDK licenses accepted
                           # (see note below)
flutter build web
```

## Notes

- Android builds need `flutter doctor --android-licenses`, which cannot run
  in this sandbox yet: Java networking is blocked by the `other_tcp`
  permission (Muse Settings → Permissions → Direct network protocols →
  Deny → Ask). Linux builds work fine.
- iOS/macOS/Windows builds cannot run on this Linux machine; their platform
  folders are generated and ready for a Mac/Windows machine.
- `apt-get update` hangs on the `mirror.cogentco.com` Ubuntu mirror — if it
  stalls, temporarily drop that URI from
  `/etc/apt/sources.list.d/ubuntu.sources` and use `azure.archive.ubuntu.com`
  only. VM replacements wipe apt-installed packages (clang/ninja/GTK) while
  home-persisted installs survive; re-check the toolchain after a restart.
