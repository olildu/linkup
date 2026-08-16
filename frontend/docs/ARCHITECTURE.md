# Architecture & Migration Guide

This document explains how the Linkup Flutter codebase is structured, why it was designed this way, and how to orient yourself if you're coming from an earlier version.

---

## Why This Architecture Exists

The original codebase worked, but it had a structural problem that would have compounded as the app grew:

**BLoCs called HTTP services directly.** There was no domain layer — models doubled as domain objects, HTTP service classes used static methods, and business logic was scattered across layers.

The first rewrite introduced a strict four-layer Clean Architecture boundary (`core` → `domain` → `data` → `presentation`), each layer only knowing about the layer directly below it. That fixed the coupling problem, but at 9+ features it created a new one: understanding or safely changing one feature meant touching 5+ unrelated top-level folders (`domain/entities/`, `domain/use_cases/likes/`, `data/repositories/`, `data/datasources/remote/`, `logic/bloc/likes/`, `presentation/screens/`), each shared by every other feature too.

The second rewrite kept every Clean Architecture layer boundary exactly as-is, but **regrouped by feature instead of by layer**. Each feature now owns one folder containing its own `data/`, `domain/`, and `presentation/` subfolders.

---

## Layer Reference

```
lib/
├── core/            Infrastructure with zero feature/business knowledge
├── shared_ui/        Cross-feature theme, widgets, generic utils
├── features/
│   ├── auth/                 data/ domain/ presentation/
│   ├── onboarding/           data/ presentation/           (no domain of its own — see below)
│   ├── city_lookup/          data/ domain/ presentation/
│   ├── discovery/            data/ domain/ presentation/    (swipe deck + match celebration)
│   ├── connections/          data/ domain/ presentation/    (matched users + chat list)
│   ├── messaging/            data/ domain/ presentation/    (real-time chat)
│   ├── lobby/                data/ presentation/            (Meet at 8)
│   ├── likes/                data/ domain/ presentation/
│   ├── profile/              data/ domain/ presentation/    (own + other profiles, preferences, media)
│   └── settings/             data/ presentation/            (account, biometric lock)
└── main.dart
```

Within each feature, the same layer rule from the original Clean Architecture rewrite still applies:

```
presentation/  →  domain/  →  data/  →  core/
(depends on)      (depends on)  (depends on)
```

`data/` implements `domain/`'s repository interfaces. `presentation/` (BLoCs/cubits + screens) only calls `domain/` use cases — it never imports a repository implementation or datasource directly.

---

### `core/` — shared infrastructure

No business logic, no knowledge of any feature.

| Path | Responsibility |
|------|---------------|
| `core/network/custom_http_client.dart` | Authenticated HTTP with automatic token refresh on 401/403 |
| `core/network/token_service.dart` | Read, write, and clear JWT tokens in `FlutterSecureStorage` |
| `core/network/base_socket_service.dart` | Shared WebSocket base — auto-reconnect, keepalive ping, token refresh |
| `core/di/injection_container.dart` | Single `initDependencies()` that wires the entire dependency graph |
| `core/constants/app_constants.dart` | `BASE_URL`, `WS_BASE_URL` |
| `core/enums/`, `core/errors/` | Shared enums and error types |
| `core/entities/` | Entities genuinely shared by 3+ features (`MatchesConnectionEntity` — used by discovery, lobby, and connections; `UpdateMetadataModel` — used by auth and profile) |
| `core/utils/` | Cross-feature helpers (age calculation, validators) |
| `core/cubits/` | App-wide cubits not owned by one feature (theme, connectivity) |

### `shared_ui/` — cross-feature presentation

Widgets, theme tokens, and screen-agnostic utilities used by more than one feature — e.g. `shared_ui/components/candidate_detail_scroll/` (used by both `discovery`'s `AroundYouPage` and `profile`'s `UserProfileBottomSheet`), `shared_ui/theme/`, `shared_ui/components/common/`.

`shared_ui/screens/match_making_page.dart` is the bottom-nav shell screen that composes `discovery`, `likes`, `connections`, and `profile` — it isn't owned by any single feature, so it lives here rather than inside one.

### `features/<name>/`

Each feature folder mirrors the original Clean Architecture layers, scoped to just that feature:

- **`data/`** — datasources (remote/local/socket), repository implementations, JSON models. Converts models → entities before returning anything to `domain/`.
- **`domain/`** — entities, abstract repository interfaces, use cases (one class per action). Zero Flutter or HTTP imports.
- **`presentation/`** — BLoCs/cubits (`presentation/bloc/`) and screens (`presentation/screens/`). Only depends on the feature's own `domain/` use cases.

Two features are thinner than the rest by design, not by omission:

- **`onboarding/`** has no `domain/` of its own — `PostLoginBloc` is a pure orchestrator that sequences other features' existing blocs (`ProfileBloc`, `MatchesBloc`, `ConnectionsBloc`, `LikesBloc`, socket blocs) rather than owning any data or business logic. `SignupBloc`'s domain use case (`CompleteProfileUseCase`) lives in `auth/domain/` since it calls `AuthRepository`.
- **`lobby/`** has no `domain/` — `LobbyBloc` parses WebSocket JSON directly into the shared `core/entities/matches_connection_entity.dart`.

**Expected cross-feature imports** (not a smell — these reflect real product relationships):
- `onboarding` → `auth`, `profile` (calls their use cases directly)
- `connections` → `core/entities/matches_connection_entity.dart` (shared with `discovery`, `lobby`)
- `shared_ui/screens/match_making_page.dart` → `discovery`, `likes`, `connections`, `profile`, `lobby` (it's the nav shell)

---

## Dependency Injection

Unchanged in mechanics from the original migration — still one `initDependencies()` in `core/di/injection_container.dart`, still registered in the order datasource → repository → use case → bloc, still using `registerSingleton` / `registerLazySingleton` / `registerFactory` per `docs/dependency_injection_guide.md`. The only difference is every registered class now imports from `features/<name>/...` instead of `data/`, `domain/`, `logic/`.

---

## WebSocket Architecture

```
BaseSocketService  (lib/core/network/base_socket_service.dart)
│  auto-reconnect · 6 s ping · 401 token-refresh
│
├── messaging/data/chat_socket_service.dart         → ChatSocketsBloc    → ChatPage
├── connections/data/connections_socket_services.dart → ConnectionsSocketBloc → ConnectionsPage
└── lobby/data/lobby_socket_service.dart            → LobbyBloc          → MeetAt8Page
```

---

## Migration History

| Migration | What changed | Status |
|-----------|--------------|--------|
| Clean Architecture rewrite | Introduced `domain/`/`data/`/`presentation/`/`core/` layer boundary, replacing static HTTP services and scattered business logic | Complete |
| Feature-slice restructure | Regrouped the same layers under `features/<name>/` instead of top-level layer folders; monorepo merge with `linkup-backend` under a shared `backend/` root | Complete |

`fvm flutter analyze` reports **0 issues** (0 errors, 0 warnings, 0 info) post-restructure. See `docs/feature_development_guide.md` for the worked "add a feature" example under the new layout.
