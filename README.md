# MediaShelf

A cross-platform **Digital Asset Manager (DAM)** built with Flutter — manage your local media library across Linux, Windows, macOS, Android and iOS.

MediaShelf is a port of [Nexus Explorer](https://github.com/Fenron-dev/nexus-explorer) with full library compatibility (shared `.mediashelf/index.db` schema and Smart Filter JSON format).

---

## Features (Phase 1 MVP)

- **Multi-platform** — Linux · Windows · macOS · Android · iOS (one codebase)
- **Self-contained libraries** — every library is a folder with `.mediashelf/index.db`; move it anywhere and it still works
- **Fast file scanner** — runs in a Dart Isolate, MD5-based move/rename detection, FTS5 full-text search
- **Auto-thumbnails** — 256 × 256 JPEG cache, generated in an Isolate pool (4 workers)
- **Smart Filters** — rule-based JSON queries (`{logic, rules}`) compatible with Nexus Explorer
- **Rich metadata** — star rating (0–5), color labels, free-text notes, tags, collections
- **Media playback** — video (chewie) and audio (just_audio) with resume support
- **Responsive layout** — 3-panel desktop shell (sidebar · grid · detail panel) and mobile bottom-nav shell
- **Filesystem watcher** — live updates with 800 ms debounce
- **Activity Journal** — tracks added / missing / restored events

## Roadmap

| Phase | Scope |
|-------|-------|
| **1 — MVP** (current) | Core DAM: scanner, thumbnails, tags, collections, smart filters, basic player |
| 2 | AI features: semantic search, auto-tagging, duplicate detection |
| 3 | Sync: multi-device, cloud backup |
| 4 | Extended formats: EPUB reader, advanced video analysis |

---

## Getting Started

### Prerequisites

```bash
flutter --version   # >= 3.41
```

On **Linux** the video player needs GStreamer:

```bash
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
                 gstreamer1.0-plugins-good gstreamer1.0-plugins-bad
```

### Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d linux        # or: windows / macos / android / ios
```

### Build (release)

```bash
flutter build linux --release
```

---

## Architecture

```
lib/
├── core/            # Constants, file hashing (MD5), MIME resolver
├── data/
│   ├── database/    # Drift ORM — 8 tables + FTS5 + triggers, 4 DAOs
│   ├── scanner/     # LibraryScanner (Dart Isolate, sqlite3 direct)
│   ├── thumbnailer/ # ensureThumbnail (Isolate pool, image pkg)
│   ├── watcher/     # LibraryWatcher (watcher pkg, 800 ms debounce)
│   └── repositories/
├── domain/models/   # AssetFilter, ScanResult
├── providers/       # Riverpod state (library, assets, tags, scan, playback …)
└── ui/
    ├── screens/     # WelcomeScreen, LibraryScreen, PlayerScreen, ActivityScreen
    ├── layout/      # ResponsiveShell → DesktopShell / MobileShell
    └── widgets/     # AssetGrid, AssetCard, ThumbnailImage, Sidebar, DetailPanel …
```

**State management:** Riverpod 2
**Navigation:** go_router 14
**Database:** Drift 2 + sqlite3_flutter_libs (FTS5 enabled)
**Thumbnails:** image 4 (pure Dart, Isolate-safe)
**Media:** video_player + chewie (video) · just_audio (audio)

---

## Library Compatibility

MediaShelf libraries are **fully compatible** with Nexus Explorer:

- Same folder layout: `<root>/.mediashelf/index.db` + `<root>/.mediashelf/thumbnails/`
- Identical SQL schema (same column names, types, defaults)
- Smart Filter JSON format: `{"logic":"AND","rules":[…]}` — identical on both apps

You can open the same library folder in either application without migration.

---

## License

MIT — see [LICENSE](LICENSE)
