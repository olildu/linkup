<p align="center">
  <img src="https://raw.githubusercontent.com/olildu/linkup-frontend/refs/heads/main/assets/images/app_logo/app_logo_transparent.png" 
       alt="linkup Logo" 
       width="180">
</p>

# Linkup — Flutter Frontend

**A real-time campus social app.** Linkup lets university students discover, match, and chat with people on their campus — with card-based swiping, WebSocket messaging, an experimental timed group-match feature (Meet at 8), and an offline-first architecture that keeps the experience smooth on patchy campus Wi-Fi.

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

- **33 use cases** across 6 domains — every BLoC receives dependencies via constructor injection; no static HTTP calls anywhere in the presentation layer
- **Auto-reconnecting WebSocket** — `BaseSocketService` handles exponential-backoff reconnect, 6-second keepalive pings, and transparent JWT refresh on 401 disconnections, across three typed channels (chat, connections, lobby)
- **Automatic token refresh** — `CustomHttpClient` silently refreshes expired access tokens and retries the failed request; BLoCs never handle token expiry
- **Durable unsent message queue** — failed messages are written to Isar and replayed in order when the socket reconnects, surviving full app restarts
- **Blurhash pipeline** — every profile photo generates a server-side blurhash so placeholders render instantly while full images load
- **`fvm flutter analyze` → 0 issues** (0 errors, 0 warnings, 0 info)

---

## Project Structure

```
lib/
├── core/               # HTTP client, token service, DI container, enums, constants
├── domain/
│   ├── entities/       # 7 pure-Dart domain objects (no JSON or Isar annotations)
│   ├── repositories/   # 6 abstract repository interfaces
│   └── use_cases/      # 33 single-responsibility callable use cases
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
    ├── screens/        # 19 screens
    ├── components/     # Reusable widgets
    ├── theme/          # AppTheme, typography, colour constants
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

| Document | What's inside |
|----------|--------------|
| [Architecture & Migration Guide](docs/ARCHITECTURE.md) | Before/after comparison of the clean architecture migration, layer-by-layer breakdown with real code snippets, full request lifecycle trace (tap → server → UI), WebSocket architecture, DI cheat sheet, legacy code inventory |
| [Feature Breakdown](docs/FEATURES.md) | All 9 features described with screens, BLoC responsible, ASCII data-flow diagrams, and one notable implementation detail per feature |
