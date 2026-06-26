# AGENTS.md

## Project overview

Flutter desktop/mobile app ("课记") that converts video lectures into structured Markdown notes via local FFmpeg audio extraction, cloud ASR (SiliconFlow/OpenAI-compatible), and cloud LLM APIs.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates *.g.dart files
flutter analyze                                            # lint + static analysis
flutter run -d windows                                     # or -d macos, -d linux, -d edge
```

Run `flutter analyze` after every change — it's the project's only static check.

## Architecture

- **Entry**: `lib/main.dart` → `ProviderScope` → `KeejiApp` (ConsumerWidget)
- **State**: Riverpod providers in `lib/core/providers.dart` — all services are singletons via `Provider`
- **Routing**: go_router `ShellRoute` wraps home/settings with `AdaptiveScaffold` (NavigationRail sidebar); `/import` is a standalone route
- **Database**: sqflite (not drift) — manual SQL in `AppDatabase` singleton, no DAOs, no ORM
- **Models**: `@JsonSerializable()` with generated `.g.dart` files
- **Services**: singletons (`factory Foo() => _instance`) — ASR, LLM, FFmpeg, VideoProcessor, ExportService
- **Processing pipeline**: `VideoProcessor.processVideo()` orchestrates extract→transcribe→generate→save sequentially

## Key gotchas

1. **README is stale** — it claims drift, media_kit, and DAOs exist. The actual codebase uses sqflite, placeholder video player, and direct `AppDatabase` methods. Trust `pubspec.yaml` and `lib/` over README.
2. **FFmpeg is not bundled** — `FFmpegService` calls system `ffmpeg`/`ffprobe` via `Process.run`. On Windows it uses `where` to find it; macOS expects `/usr/local/bin/ffmpeg`. Users must install FFmpeg separately.
3. **API keys stored in SharedPreferences** — ASR/LLM config is persisted client-side. No encryption.
4. **Video status is an enum index** — `VideoStatus` values are stored as integers (0=pending, 1=processing, 2=done, 3=failed) in SQLite. Don't reorder the enum.
5. **Models use `copyWith` manually** — no freezed, so model changes require updating both the class and its `copyWith` method by hand.
6. **Video player is a placeholder** — `VideoPlayerWidget` is a static UI mock, not wired to actual playback.

## Code generation

Models in `lib/models/` use `@JsonSerializable()` and require `build_runner`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files: `video_record.g.dart`, `note.g.dart`. Don't edit them manually.

## Platform notes

- **Desktop**: NavigationRail sidebar layout; FFmpeg via system process
- **Mobile**: intended but not fully wired (FFmpeg mobile strategy TBD)
- **Web**: runs but FFmpeg/video features won't work
- Windows desktop builds require Visual Studio with "Desktop development with C++" workload
