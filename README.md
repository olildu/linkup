<p align="center">
  <img src="https://raw.githubusercontent.com/olildu/linkup-frontend/refs/heads/main/assets/images/app_logo/app_logo_transparent.png" 
       alt="linkup Logo" 
       width="180">
</p>

# Linkup — Flutter Frontend

**A real-time campus social app.** Linkup lets university students discover, match, and chat with people on their campus — card-based swiping, WebSocket messaging, an experimental timed group-match feature (Meet at 8), and an offline-first architecture that keeps the experience smooth on patchy campus Wi-Fi.

<p align="center">
  <a href="https://x.com/olildu">
    <img src="https://img.shields.io/twitter/follow/your_twitter_handle.svg?style=social&label=Follow" alt="Twitter">
  </a>
  &nbsp;&nbsp;
  <a href="https://www.linkedin.com/in/ebinsanthosh/">
    <img src="https://img.shields.io/badge/LinkedIn-Connect-0A66C2?logo=linkedin&logoColor=white" alt="LinkedIn">
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Architecture-Clean_Architecture-4CAF50" alt="Clean Architecture">
  <img src="https://img.shields.io/badge/State-BLoC-blueviolet" alt="BLoC">
  <img src="https://img.shields.io/badge/Local_DB-Isar-orange" alt="Isar">
  <img src="https://img.shields.io/badge/Realtime-WebSocket-brightgreen" alt="WebSocket">
  <img src="https://img.shields.io/badge/Analyzer-0_issues-success" alt="Analyzer">
</p>

---

## Try It Now

The app is in active beta. No backend setup required.

**[Download the latest APK (v1.0.0)](https://github.com/olildu/linkup-frontend/releases/download/v1.0.0-beta/app-release.apk)**

> Test account — email: `tester@linkup.olildu.dpdns.org` · password: `TESTERcreds#40`

---

## What It Does

| Feature | Description |
|---------|-------------|
| **Profile Discovery** | Card-stack swiping through campus profiles; mutual likes produce a match |
| **Real-Time Chat** | WebSocket messaging with typing indicators, seen receipts, image sharing, reply threading, and an offline unsent-message queue |
| **Meet at 8** | A time-gated lobby feature — users are auto-matched when the lobby fills |
| **Offline-First** | Messages and connections cache to Isar; the UI renders from local storage before the network responds |
| **Biometric App Lock** | Fingerprint / Face ID gate on cold launch via `local_auth` |
| **Match Celebration** | Confetti, haptic feedback, and a one-tap path into the new chat room on every match |

---

## Architecture

The codebase is structured around clean architecture with four strict layers. Dependencies only point inward — presentation knows nothing about HTTP, domain knows nothing about Flutter.

```
┌─────────────────────────────────────────────────────────┐
│  Presentation  (lib/logic/ · lib/presentation/)         │
│  Screens · BLoCs · Cubits                               │
│  All state via constructor-injected use cases           │
├─────────────────────────────────────────────────────────┤
│  Domain  (lib/domain/)                                  │
│  Entities · Repository Interfaces · Use Cases           │
│  Pure Dart — zero Flutter or HTTP imports               │
├─────────────────────────────────────────────────────────┤
│  Data  (lib/data/)                                      │
│  Remote · Local · Socket Datasources                    │
│  Repository Implementations · Models                    │
├─────────────────────────────────────────────────────────┤
│  Core  (lib/core/)                                      │
│  HTTP Client (auto token-refresh) · Token Service · DI  │
└─────────────────────────────────────────────────────────┘
```

**Key technical highlights:**

- **34 use cases** across 6 domains — every BLoC receives dependencies via constructor injection; no static HTTP calls anywhere in the presentation layer
- **Auto-reconnecting WebSocket** — `BaseSocketService` handles exponential-backoff reconnect, 6-second keepalive pings, and transparent JWT refresh on 401 disconnections, across three typed channels (chat, connections, lobby)
- **Automatic token refresh** — `CustomHttpClient` silently refreshes expired access tokens and retries the failed request; BLoCs never handle token expiry
- **Durable unsent message queue** — failed messages are written to Isar and replayed in order when the socket reconnects, surviving full app restarts
- **Blurhash pipeline** — every profile photo generates a server-side blurhash so placeholders render instantly while full images load

---

## Design System

The entire UI runs on a structured token-based design system — no hardcoded colours, sizes, or text styles anywhere in screens or components. This was built from scratch as a deliberate migration across all 20 screens, 7 components, and 230 Dart files.

**Token files — the single source of truth:**

| File | What it owns |
|------|-------------|
| `lib/presentation/constants/colors.dart` | `AppColors` — semantic color tokens built on a private `_Palette` of raw hex values |
| `lib/presentation/theme/app_theme.dart` | `AppTheme.light()` / `AppTheme.dark()` — full `ThemeData` with wired `ColorScheme`, `InputDecorationTheme`, `ElevatedButtonTheme`, `CardTheme` |
| `lib/presentation/theme/app_typography.dart` | `AppTypography` — all font sizes and weights mapped to `TextTheme` slots |
| `lib/presentation/theme/app_spacing.dart` | `AppSpacing` — a named spacing scale (`xxs` → `xl5`) |
| `lib/presentation/theme/app_radius.dart` | `AppRadius` — named border-radius tokens |
| `lib/presentation/theme/app_shadows.dart` | `AppShadows` — named `BoxShadow` values |
| `lib/presentation/theme/theme_extensions.dart` | `context.colors` / `context.textTheme` — ergonomic shortcuts |

**The rules (enforced across the codebase):**

```dart
// Colors — always via colorScheme, never raw hex
color: Theme.of(context).colorScheme.primary      // ✓
color: const Color(0xFF00B3B3)                     // ✗

// Text styles — always from TextTheme, never inline overrides
style: Theme.of(context).textTheme.headlineMedium  // ✓
style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)  // ✗

// Spacing — always named tokens
EdgeInsets.all(AppSpacing.lg)                      // ✓
EdgeInsets.all(16)                                 // ✗
```

The migration covered **44 tasks across 5 phases** — token extraction, bug fixes (an `0xFA`-alpha rendering bug), component migration, screen migration, and cleanup (removing stale constants, documenting lint conventions, auditing all remaining `fontSize:`/`FontWeight.` overrides).

---

## Project Structure

```
lib/
├── core/               # HTTP client, token service, DI container, enums, constants
├── domain/
│   ├── entities/       # 7 pure-Dart domain objects (no JSON or Isar annotations)
│   ├── repositories/   # 6 abstract repository interfaces
│   └── use_cases/      # 34 single-responsibility callable use cases
├── data/
│   ├── datasources/
│   │   ├── remote/     # 7 HTTP datasources (instance methods, typed Dart records)
│   │   ├── local/      # 2 Isar datasources — messages, chat connections
│   │   └── socket/     # 3 WebSocket datasources — chat, connections, lobby
│   ├── repositories/   # 6 repository implementations
│   ├── models/         # JSON-annotated API response models
│   └── isar_classes/   # Isar schema definitions
├── logic/
│   ├── bloc/           # 13 BLoCs — auth, matches, chats, profile, sockets, …
│   └── cubit/          # 3 Cubits — theme, app lock, connectivity
└── presentation/
    ├── screens/        # 20 screens
    ├── components/     # Reusable widgets
    ├── theme/          # AppTheme, AppTypography, AppSpacing, AppRadius, AppShadows
    ├── constants/      # AppColors, AppTextStyles
    └── utils/          # Blurhash helper, toast, navigation utilities
```

---

## Getting Started

The project uses [FVM](https://fvm.app) to pin the Flutter version.

```bash
# Install the pinned Flutter version (3.44.1)
fvm install

# Install dependencies
fvm flutter pub get

# Run on a connected device or simulator
fvm flutter run
```

> You'll need the FastAPI backend running or pointed at the live server. Set `BASE_URL` and `WS_BASE_URL` in `lib/core/constants/app_constants.dart`.

---

## Documentation

The `docs/` folder contains eight reference documents covering every layer of the codebase. Each doc is written to be useful independently — you can start from any layer without reading the others.

**New to the codebase? Read in this order:**

1. [Architecture Overview](docs/architecture_overview.md) — the 4-layer structure and how data flows end to end
2. [Feature Development Guide](docs/feature_development_guide.md) — step-by-step walkthrough: API → entity → use case → BLoC → widget
3. [State Management Guide](docs/state_management_guide.md) — BLoC vs Cubit, singleton vs factory, BlocBuilder/Listener/Consumer patterns
4. [Design System Guide](docs/design_system_guide.md) — colors, typography, spacing, radius — the rules for all UI code

**Full reference index:**

| Document | What's inside |
|----------|--------------|
| [Architecture Overview](docs/architecture_overview.md) | The 4 layers (data/domain/logic/presentation), what lives where, dependency rules, full request lifecycle trace |
| [Feature Development Guide](docs/feature_development_guide.md) | End-to-end worked example — the canonical "how to add a feature" |
| [State Management Guide](docs/state_management_guide.md) | BLoC vs Cubit, singleton vs factory, BlocBuilder/Listener/Consumer patterns |
| [Dependency Injection Guide](docs/dependency_injection_guide.md) | GetIt, `sl<T>()`, registration types, how to add a new dependency |
| [WebSocket Guide](docs/websocket_guide.md) | The 3 socket services (chat, connections, lobby), `BaseSocketService`, unsent message queue |
| [Local Persistence Guide](docs/local_persistence_guide.md) | Isar (messages/chats), SharedPreferences (theme, app lock), FlutterSecureStorage (tokens) |
| [Navigation Guide](docs/navigation_guide.md) | Navigator patterns, CupertinoPageRoute, bottom sheets, post-login routing |
| [Design System Guide](docs/design_system_guide.md) | Colors, typography, spacing, radius — full rules with before/after examples |
| [Architecture & Migration Guide](docs/ARCHITECTURE.md) | Before/after comparison of the clean architecture migration, layer-by-layer breakdown with real code snippets, WebSocket architecture, DI cheat sheet |
| [Feature Breakdown](docs/FEATURES.md) | All 9 features described with screens, BLoC responsible, ASCII data-flow diagrams, and notable implementation details |
